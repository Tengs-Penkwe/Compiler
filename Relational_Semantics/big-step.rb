class Number < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    self
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    self
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    environment[name]
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect 
    "<<#{self}>>"
  end
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end
  def inspect 
    "<<#{self}>>"
  end
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    environment.merge( {name => expression.evaluate(environment)} )
  end
end

class If < Struct.new(:cond, :expr, :alter) 
  def to_s 
    "#if(#{cond}) {#{expr}} else {#{alter}}"
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    if cond.evaluate(environment) 
      expr.evaluate(environment)
    else
      alter.evaluate(environment)
    end
  end
end

class Sequence < Struct.new(:first, :second) 
  def to_s
    "#{first} ; #{second}"
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    #if first.evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

class While < Struct.new(:cond, :expr)
  def to_s
    "while (#{cond}) {#{expr}}"
  end
  def inspect
    "<<#{self}>>"
  end
  def evaluate(environment)
    case cond.evaluate(environment)
    when Boolean.new(true)
      While.new(cond,expr).evaluate(expr.evaluate(environment))
    #else
    when Boolean.new(false)
      environment
    end
  end
end
