class FARule < Struct.new(:state, :char, :next_state)
  def applies_to?(state, char)
    self.state == state && self.char == char
  end
  def follow
    next_state
  end
  def inspect
    "#<FARule #{state.inspect} --#{char}--> #{next_state.inspect}>"
  end
end

class DFARulebook < Struct.new(:rules)
  def rule_for(state, char)
    rules.detect {|rule| rule.applies_to?(state, char)}
  end
  def next_state(state, char)
    rule_for(state, char).follow
  end
end

class DFA < Struct.new(:current, :accept, :rulebook)
  def accepting?
    accept.include?(current_state)
  end
  def read_character(char)
    self.current = rulebook.next_state(current, char)
  end
  def read_string(string)
    string.chars.each do |char|
      read_character(char)
    end
  end
end

class DFADesign < Struct.new(:current, :accept, :rulebook) 
  def to_dfa
    DFA.new(current, accept, rulebook)
  end
  def accepts?(string)
    dfa = to_dfa.read_string(string)
    dfa.accepting?
  end
end

require 'set'
class NFARulebook < Struct.new(:rules)
  def next_states(states, char)
    states.flat_map {|state| follow_rules(state, char)}.to_set
  end
  def follow_rules(state, char)
    rules_for(state, char).map(&:follow)
  end
  def rules_for(state, char)
    rules.select {|rule| rule.applies_to?(state, char)}
  end
  def follow_free_moves(states)
    [ next_states(states, nil), states].to_set.flatten
    # if !more_states.subset?(states)
    # end
  end
  def method_missing(method, *args)
    puts "#{args}"
    puts "no #{method}"
  end
end

class NFA < Struct.new(:current, :accept, :rulebook)
  def current  
    rulebook.follow_free_moves(super)
  end
  def accepting?
    (current & accept).any?
  end
  def read_character(char)
    self.current = rulebook.next_states(current, char)
  end
  def read_string(string)
    string.chars.each do |char|
      read_character(char)
    end
  end
end

class NFADesign < Struct.new(:current, :accept, :rulebook)
  def to_nfa
    NFA.new(current, accept, rulebook)
  end
  def accepts?(string)
    # nfa = to_nfa.read_string(string)
    # nfa.accepting?
    to_nfa.tap {|nfa| nfa.read_string(string)}.accepting?
  end
end

$rulebook = NFARulebook.new([
  FARule.new(1, nil, 2), FARule.new(1, nil, 4),
  FARule.new(2, 'a', 3),
  FARule.new(3, 'a', 2),
  FARule.new(4, 'a', 5),
  FARule.new(5, 'a', 6),
  FARule.new(6, 'a', 4)
])
