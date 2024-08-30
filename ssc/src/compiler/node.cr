module SSC
  abstract class Node
    abstract def type : String
    abstract def to_s(io : IO) : Nil
    abstract def pretty_print(pp : PrettyPrint) : Nil
  end

  abstract class Expression < Node
  end

  class Identifier < Expression
    getter value : String

    def initialize(@value)
    end

    def type : String
      "identifier"
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "Identifier("
      @value.pretty_print pp
      pp.text ")"
    end
  end

  class StringLiteral < Expression
    getter value : String

    def initialize(@value)
    end

    def type : String
      "string"
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "StringLiteral("
      @value.pretty_print pp
      pp.text ")"
    end
  end

  class IntegerLiteral < Expression
    getter value : Int64

    def initialize(@value)
    end

    def type : String
      "integer"
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "IntegerLiteral("
      @value.pretty_print pp
      pp.text ")"
    end
  end

  class FloatLiteral < Expression
    getter value : Float64

    def initialize(@value)
    end

    def type : String
      "float"
    end

    def to_s(io : IO) : Nil
      io << @value
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "FloatLiteral("
      @value.pretty_print pp
      pp.text ")"
    end
  end

  class Call < Expression
    getter func : Expression
    getter args : Array(Expression)

    def initialize(@func, @args)
    end

    def type : String
      "call"
    end

    def to_s(io : IO) : Nil
      func.to_s io

      unless @args.empty?
        io << " with "

        if @args.size == 1
          args[0].to_s io
        else
          args[..-1].join(io, ", ")
          io << " and "
          args[-1].to_s io
        end
      end
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "Call("
      pp.group 1 do
        pp.breakable ""
        pp.text "@func="
        @func.pretty_print pp
        pp.comma

        pp.text "@args="
        @args.pretty_print pp
      end
      pp.text ")"
    end
  end

  abstract class Statement < Node
  end

  class ExpressionStatement < Statement
    getter expr : Expression

    def initialize(@expr)
    end

    def type : String
      @expr.type
    end

    def to_s(io : IO) : Nil
      @expr.to_s io
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "ExpressionStatement("
      pp.group 1 do
        pp.breakable ""
        @expr.pretty_print pp
      end
      pp.text ")"
    end
  end

  class SetValue < Statement
    getter name : Expression
    getter value : Expression

    def initialize(@name, @value)
    end

    def type : String
      "set type"
    end

    def to_s(io : IO) : Nil
      io << "set "
      @name.to_s io
      io << " to "
      @value.to_s io
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "SetValue("
      pp.group 1 do
        pp.breakable ""
        pp.text "@name="
        @name.pretty_print pp
        pp.comma

        pp.text "@value="
        @value.pretty_print pp
      end
      pp.text ")"
    end
  end
end
