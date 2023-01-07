class Number < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e {e[#{name.inspect}]}"
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    #"-> e { #{name.to_ruby} = (#{expression.to_ruby})}"
    "-> e { e.merge( {#{name.inspect}=> (#{expression.to_ruby}).call(e)} ) }"
  end
end

class If < Struct.new(:cond, :expr, :alter)
  def to_s
    "#if(#{cond}) {#{expr}} else {#{alter}}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { if (#{cond.to_ruby}).call(e) " +
    "then (#{expr.to_ruby}).call(e) " +
    "else (#{alter.to_ruby}).call(e)" +
    "end }"
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first} ; #{second}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    #"-> e { #{first.to_ruby}.call(e)" +
    #  " #{second.to_ruby}.call(e) }"
    "-> e { (#second.to_ruby).call(#{first.to_ruby}.call(e)) }"
  end
end

class While < Struct.new(:cond, :expr)
  def to_s
    "while (#{cond}) {#{expr}}"
  end
  def inspect
    "<<#{self}>>"
  end
  def to_ruby
    "-> e { while (#{cond.to_ruby}).call(e);" +
      " e = (#{expr.to_ruby}).call(e);" +
      " end; e }"
  end
end
