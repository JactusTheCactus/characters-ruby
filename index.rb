#!/usr/bin/env ruby
def uni(u = 0x0)
  "&#%s;" % [u]
end
ACUTE = uni 0x0301
GRAVE = uni 0x0300
OMEGA = uni 0x03C9
SCHWA = uni 0x0259
ASH = uni 0x00E6
E_ = "e%s" % [uni(0x0323)]
MALE = uni 0x2642
FEMALE = uni 0x2640
NEUTER = uni 0x26A5
def env(var)
  ENV[var.to_s]
end

def filter(x)
  x
    .gsub("<", uni(0x3C))
    .gsub(">", uni(0x3E))
end

def getSex(sex = :neuter)
  case sex
  when :male then MALE
  when :female then FEMALE
  else NEUTER
  end
end

def getInfo(form, label, list)
  case form
  when :html
    [El.new(:dt, label),
      El.new(:dd, El.new(:code,
        if list.length > 1
          El.new(:ol, *list.map { |s| El.new(:li, s.to_s) })
        else
          El.new(:span, list[0].to_s)
        end))]
  when :md
    o = ["### #{label}"]
    list.each { |i|
      o.append "- #{i}"
    }
    o
  end
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
    @sex = getSex(sex)
    @species = species
    @extra = extra
  end

  def to_el
    El.new(:dl,
      El.new(:dt, El.new(:sup, @sex), @name.join(" ")),
      El.new(:dd, filter("<%s>" % [@pron.join("|")])),
      *getInfo(:html, :Species, @species),
      *getInfo(:html, :Extra, @extra))
  end

  def to_s
    to_el.to_s
  end
end
characters = [[:female,
  ["Hound", "NcNamara"],
  ["haund",
    "ny%skn%sm%s%sr%s" % [ACUTE, SCHWA, E_, GRAVE, SCHWA]],
  [:Human, :Changeling],
  ["Shapeshifts into a large, black wolf"]],
  [:female,
    ["Morrigan", "Heffernan"],
    ["m%s%sr%sgy%sn" % [OMEGA, ACUTE, SCHWA, GRAVE],
      "he%sf%srn%s%sn" % [ACUTE, SCHWA, ASH, GRAVE]],
    [:Reaper],
    ["Killing touch", "Wields a scythe"]]]
html = [El.new(:html,
  El.new(:head, El.new(:style, env(:style))),
  El.new(:body, *characters.map { |c| Character.new(*c) }))]
characters.map! { |c|
  {
    sex: getSex(c[0]),
    name: c[1].join(" "),
    pron: filter("<%s>" % [c[2].join("|")]),
    species: c[3].map { |s| s.to_s },
    extra: c[4]
  }
}
md = []
characters.each { |c|
  md.append "# #{c[:sex]}#{c[:name]}"
  md.append "## #{c[:pron]}"
  stats = [["Species", :species],
    ["Extra", :extra]].map { |s|
    getInfo(:md, s[0], c[s[1]])
  }
  md.append(*stats)
}
puts [*html, env(:break), *md]
