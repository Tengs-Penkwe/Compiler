require './Finite_Automaton.rb'

module Pattern
  def bracket(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else 
      to_s
    end
  end
  def inspect
    "/#{self}/"
  end    
  def matches?(string)
    to_nfa_design.accepts?(string)
  end
end

class Empty
  include Pattern
  def to_s
    ''
  end
  def precedence
    3
  end
  def to_nfa_design
    start = Object.new
    accept = [start]
    rulebook = NFARulebook.new([])

    NFADesign.new(start, accept, rulebook)
  end
end

class Literal < Struct.new(:char)
  include Pattern
  def to_s
    "#{char}"
    #char
  end
  def precedence
    2
  end
  def to_nfa_design
    start = Object.new
    accept = Object.new
    rule = FARule.new(start, char, accept)
    rulebook = NFARulebook.new([rule])

    NFADesign.new(start, [accept], rulebook)
  end
end

class Concatenate < Struct.new(:left, :right)
  include Pattern
  def to_s
    [left, right].map {|pattern| pattern.bracket(precedence)}.join
  end
  def precedence
    1
  end
  def to_nfa_design
    left_nfa_design = left.to_nfa_design
    right_nfa_design = right.to_nfa_design

    start = left_nfa_design.start
    accept = right_nfa_design.accept
    rules = left_nfa_design.rulebook.rules + right_nfa_design.rulebook.rules
    extra_rules = left_nfa_design.accept.map {|state| 
      FARule.new(state, nil, right_nfa_design.start)
    }
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start, accept, rulebook)
  end    
end

class Choose < Struct.new(:left, :right)
  include Pattern
  def to_s
    [left, right].map {|pattern| pattern.bracket(precedence)}.join('|')
  end
  def precedence
    0
  end
  def to_nfa_design
    left_nfa_design = left.to_nfa_design
    right_nfa_design = right.to_nfa_design

    start = Object.new
    accept = left_nfa_design.accept + right_nfa_design.accept
    rules = left_nfa_design.rulebook.rules + right_nfa_design.rulebook.rules
    extra_rules = [left_nfa_design, right_nfa_design].map {|nfa_design| 
      FARule.new(start, nil, nfa_design.start)
    }
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start, accept, rulebook)
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern
  def to_s
    pattern.bracket(precedence) + '*'
  end
  def precedence
    2
  end
  def to_nfa_design
    nfa_design = pattern.to_nfa_design

    start = Object.new 
    accept = nfa_design.accept + [start]
    rules = nfa_design.rulebook.rules
    extra_rules = nfa_design.accept.map {|accept| 
      FARule.new(accept, nil, nfa_design.start)  
    } + [FARule.new(start, nil, nfa_design.start)]
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start, accept, rulebook)
  end
end
