#!/usr/bin/env ruby
def uni(u = 0x0)
  "&#%s;" % [u]
end
ACUTE = uni 0x0301
GRAVE = uni 0x0300
OMEGA = uni 0x03C9
SCHWA = uni 0x0259
ASH = uni 0x00E6
E_ = "e%s" % [uni 0x0323]
MALE = uni 0x2642
FEMALE = uni 0x2640
NEUTER = uni 0x26A5
def filter(x)
  x
    .gsub("<", uni(0x3C))
    .gsub(">", uni(0x3E))
end

class El
  attr_accessor :tag
  attr_accessor :children
  def initialize(tag = :span, *children)
    @tag = tag.to_s.match(/^(.*?)\.?.*$/)[0]
    @children = children
  end

  def to_s
    content = ""
    @children.each { |c|
      content += if c.is_a?(El)
        "<%s>" % [c.tag] +
          c
            .children
            .join +
          "</%s>" % [c.tag]
      elsif c.is_a?(String)
        filter(c)
      end
    }
    pre = case @tag.to_sym
    when :html
      "<!DOCTYPE html>"
    else
      ""
    end
    "%s<%s>%s</%s>" % [pre, @tag, content, @tag]
  end
end

class Character
  def initialize(sex, name, pron, species, extra)
    @name = name
    @pron = pron
    @sex = case sex
    when :male
      MALE
    when :female
      FEMALE
    else
      NEUTER
    end
    @species = species
    @extra = extra
  end

  def to_el
    El.new(:div,
      El.new(:dl,
        El.new(:dt,
          El.new(:sup,
            @sex),
          @name.join(" ")),
        El.new(:dd,
          filter("<%s>" % [@pron.join("|")])),
        El.new(:dt,
          "Species"),
        El.new(:dd,
          El.new(:ol,
            *@species.map { |s|
              El.new(:li,
                s.to_s)
            })),
        El.new(:dt,
          "Extra"),
        El.new(:dd,
          El.new(:ul,
            *@extra.map { |e|
              El.new(:li,
                e)
            }))))
  end

  def to_s
    to_el.to_s
  end
end
puts El.new(:html,
  El.new(:head,
    El.new(:style,
      ENV["style"])),
  El.new(:body,
    Character.new(:female,
      ["Hound",
        "NcNamara"],
      ["haund",
        "ny#{ACUTE}kn#{SCHWA}m#{E_}#{GRAVE}r#{SCHWA}"],
      [:Reaper],
      ["Shapeshifts Into a large, black wolf"]),
    Character.new(:female,
      ["Morrigan",
        "Heffernan"],
      ["m#{OMEGA}#{ACUTE}r#{SCHWA}gy#{GRAVE}n",
        "he#{ACUTE}f#{SCHWA}rn#{ASH}#{GRAVE}n"],
      [:Human,
        :Changeling],
      ["Killing Touch",
        "wields a scythe"])))
