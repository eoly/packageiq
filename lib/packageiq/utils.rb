module Packageiq
  module Utils
    def self.amqp_uri(options = {})
      vhost     = options[:vhost] == '/' ? '/' : ''
      scheme    = options[:tls] ? 'amqps://' : 'amqp://'
      userinfo  = options[:user] + ':' + options[:pass]
      authority = userinfo + '@' + options[:host] + ':' + options[:port].to_s
      scheme + authority + vhost
    end

    def self.rpmvercmp(str1, str2)
      return 0 if str1 == str2

      front_strip_re = /^[^A-Za-z0-9~]+/

      while str1.length > 0 or str2.length > 0
        # trim anything that's in front_strip_re and != '~' off the beginning of each string
        str1 = str1.gsub(front_strip_re, '')
        str2 = str2.gsub(front_strip_re, '')

        # "handle the tilde separator, it sorts before everything else"
        if /^~/.match(str1) && /^~/.match(str2)
          # if they both have ~, strip it
          str1 = str1[1..-1]
          str2 = str2[1..-1]
        elsif /^~/.match(str1)
          return -1
        elsif /^~/.match(str2)
          return 1
        end

        break if str1.length == 0 or str2.length == 0

        # "grab first completely alpha or completely numeric segment"
        isnum = false
        # if the first char of str1 is a digit, grab the chunk of continuous digits from each string
        if /^[0-9]+/.match(str1)
          if str1 =~ /^[0-9]+/
            segment1 = $~.to_s
            str1 = $~.post_match
          else
            segment1 = ''
          end
          if str2 =~ /^[0-9]+/
            segment2 = $~.to_s
            str2 = $~.post_match
          else
            segment2 = ''
          end
          isnum = true
        # else grab the chunk of continuous alphas from each string (which may be '')
        else
          if str1 =~ /^[A-Za-z]+/
            segment1 = $~.to_s
            str1 = $~.post_match
          else
            segment1 = ''
          end
          if str2 =~ /^[A-Za-z]+/
            segment2 = $~.to_s
            str2 = $~.post_match
          else
            segment2 = ''
          end
        end

        # if the segments we just grabbed from the strings are different types (i.e. one numeric one alpha),
        # where alpha also includes ''; "numeric segments are always newer than alpha segments"
        if segment2.length == 0
          return 1 if isnum
          return -1
        end

        if isnum
          # "throw away any leading zeros - it's a number, right?"
          segment1 = segment1.gsub(/^0+/, '')
          segment2 = segment2.gsub(/^0+/, '')
          # "whichever number has more digits wins"
          return 1 if segment1.length > segment2.length
          return -1 if segment1.length < segment2.length
        end

        # "strcmp will return which one is greater - even if the two segments are alpha
        # or if they are numeric. don't return if they are equal because there might
        # be more segments to compare"
        rc = segment1 <=> segment2
        return rc if rc != 0
      end #end while loop

      # if we haven't returned anything yet, "whichever version still has characters left over wins"
      if str1.length > str2.length
        return 1
      elsif str1.length < str2.length
        return -1
      else
        return 0
      end
    end
  end
end
