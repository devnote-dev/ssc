module SSC
  class Parser
    private enum Precedence
      Lowest
      Equals
      LessGreater
      Sum
      Product
      Prefix

      def self.from(kind : Token::Kind) : self
        case kind
        when .plus?, .minus?
          Sum
        when .asterisk?, .slash?
          Product
        else
          Lowest
        end
      end
    end

    @tokens : Array(Token)
    @pos : Int32

    def self.parse(tokens : Array(Token)) : Array(Statement)
      new(tokens).parse
    end

    private def initialize(@tokens)
      @pos = 0
    end

    def parse : Array(Statement)
      nodes = [] of Statement

      loop do
        break unless node = parse_next_statement
        nodes << node
      end

      nodes
    end

    private def parse_next_statement : Statement?
      case current_token.kind
      when .eof?
        nil
      when .space?, .newline?
        next_token
        parse_next_statement
      when .set?
        parse_set
      else
        parse_expr_statement
      end
    end

    private def current_token : Token
      @tokens[@pos]
    end

    private def peek_token(count : Int32 = 1) : Token
      @tokens[@pos + count]
    end

    private def peek_token_skip_space(count : Int32 = 1) : Token
      if (token = peek_token count).kind.space?
        peek_token_skip_space count + 1
      else
        token
      end
    end

    private def next_token : Token
      @tokens[@pos += 1]
    end

    private def next_token_skip_space : Token
      if (token = next_token).kind.space?
        next_token_skip_space
      else
        token
      end
    end

    private def parse_set : Statement
      case (token = next_token_skip_space).kind
      when .ident?
        name = parse_ident token
        # TODO: maybe warn against 'set set to ...'
      else
        raise "Expected an identifier to set, not a #{token.kind}"
      end

      unless name.is_a? Identifier
        raise "Cannot set the value of a #{name.type}"
      end

      # TODO: also check for 'as' when implemented
      unless next_token_skip_space.kind.to?
        raise "Expected keyword 'to' after 'set'"
      end

      next_token_skip_space
      value = parse_expr_statement

      SetValue.new name, value.expr
    end

    private def parse_expr_statement : Statement
      ExpressionStatement.new parse_expr :lowest
    end

    private def parse_expr(prec : Precedence) : Expression
      unless left = parse_prefix current_token
        raise "cannot parse prefix type for #{current_token.kind}"
      end

      loop do
        break if current_token.kind.eof?

        token = next_token
        break if prec >= Precedence.from(token.kind)
        break unless infix = parse_infix token.kind, left

        left = infix
      end

      left
    end

    private def parse_prefix(token : Token) : Expression?
      case token.kind
      when .ident?   then parse_ident token
      when .string?  then parse_string token
      when .integer? then parse_integer token
      when .float?   then parse_float token
      end
    end

    private def parse_infix(kind : Token::Kind, expr : Expression) : Expression?
    end

    # private def parse_infix(kind : Token::Kind, expr : Expression) : Expression?
    #   op = case token.kind
    #        when .plus?     then Operator::Add
    #        when .minus?    then Operator::Substract
    #        when .asterisk? then Operator::Multiply
    #        when .slash?    then Operator::Divide
    #        else                 return
    #        end

    #   prec = Precedence.from next_token.kind
    #   right = parse_expr prec

    #   Infix.new left, op, right
    # end

    private def parse_ident(token : Token) : Expression
      case peek_token_skip_space.kind
      when .ident?, .string?, .integer?, .float?
        parse_call token
      else
        Identifier.new token.value
      end
    end

    private def parse_string(token : Token) : Expression
      StringLiteral.new token.value
    end

    private def parse_integer(token : Token) : Expression
      IntegerLiteral.new token.value.to_i64 strict: false
    end

    private def parse_float(token : Token) : Expression
      FloatLiteral.new token.value.to_f64 strict: false
    end

    private def parse_call(token : Token) : Expression
      next_token_skip_space
      args = [parse_expr :lowest]

      if current_token.kind.eof? || !current_token.kind.comma?
        return Call.new Identifier.new(token.value), args
      end

      loop do
        case next_token.kind
        when .eof?
          break
        when .space?, .newline?
          next
        else
          args << parse_expr :lowest
          break unless current_token.kind.comma?
        end
      end

      Call.new Identifier.new(token.value), args
    end
  end
end
