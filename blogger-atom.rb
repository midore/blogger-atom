module BloggerGetHttp

  class Access

    def base(save_file, u)
      begin
        open(u){|x| File.open(save_file, 'w:utf-8'){|f| f.write x.read}}
      rescue
        return print "Access Error\n"
      end
    end

  end

  class AtomRss

    alias []= instance_variable_set
    alias [] instance_variable_get

    def base
      @save_file = @f
      unless File.exist?(@save_file)
        return nil unless get_xml
      end
      read_xml 
    end

    def read_xml
      return nil unless @save_file
      XmlGet.new(@save_file).base
    end

    def get_xml
      u = get_label_url unless @label.nil?
      u = get_range_url if (@min and @max)
      print u, "\n"
      res = Access.new().base(@save_file, u)
      return nil unless res
      sleep 1
      return true 
    end

    def get_label_url
      return "http://www.blogger.com/feeds/#{@blogid}/posts/default/-/#{@label}"
    end

    def get_range_url
      min, max = @min, @max
      begin
        t1 = Time.parse(min)
        tmin = (Time.local(t1.year, t1.month, t1.day) - 60).strftime("%Y-%m-%dT%H:%M:%S")
        # ---- max date ok? 
        t2 = Time.parse(max)
        tmax = (Time.local(t2.year, t2.month, t2.day) + 60*60*24).strftime("%Y-%m-%dT%H:%M:%S")
        return nil if t2 - t1 < 1
      rescue
        return nil
      end
      return "http://#{@blogurl}/feeds/posts/default?published-min=#{tmin}&published-max=#{tmax}"
    end

  end

  class XmlGet

    def initialize(f)
      @save_file = f
    end

    def base
      return nil unless File.exist?(@save_file)
      doc = REXML::Document.new(IO.read(@save_file))
      doc.root.get_elements('entry').each_with_index{|x,cnt|
        edit, href = '', ''
        title, pubdate, update = get_e(x,'title'), get_e(x,'published'), get_e(x,'updated')
        summary = get_e(x,'summary')
        x.get_elements('link').each{|y| 
          edit = y.attributes['href'] if y.attributes['rel'] == 'edit'
          href = y.attributes['href'] if y.attributes['rel'] == 'alternate'
        }
        output(cnt+1, [title, pubdate, update, edit, href], summary)
      }
    end

    def output(cnt, ary, str)
      print "-"*10, "#{cnt}", "\n"
      printf "Title\s\s:\s%s\nPubDate:\s%15s\nUpdate\s:\s%15s\nEditURL:\s%s\nParmLink:\s%s\n" % ary
      print str, "\n"
    end

    def get_e(x, str)
      x.elements[str].text if x.elements
    end

    def get_att(x, att)
      x.attributes[att]
    end
 
  end

end
