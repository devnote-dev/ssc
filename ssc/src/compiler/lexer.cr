module SSC
  class Lexer
    @reader : Char::Reader
    @pool : StringPool

    def self.lex(source : String)
      new(source).lex
    end

    private def initialize(source : String)
      @reader = Char::Reader.new source
      @pool = StringPool.new
    end

    def lex : Array(Token)
      tokens = [] of Token

      loop do
        tokens << (token = lex_next_token)
        break if token.kind.eof?
      end

      tokens
    end

    private def lex_next_token : Token
      case current_char
      when '\0'
        Token.new :eof
      when ' '
        lex_space
      when '\r', '\n'
        lex_newline
      when '_', .ascii_letter?
        lex_ident
      when '"'
        lex_string
      when .ascii_number?
        lex_number
      when '+'
        next_char
        Token.new :plus
      when '-'
        next_char
        Token.new :minus
      when '*'
        next_char
        Token.new :asterisk
      when '/'
        next_char
        Token.new :slash
      when ','
        next_char
        Token.new :comma
      else
        raise "unexpected character #{current_char.inspect}"
      end
    end

    private def current_char : Char
      @reader.current_char
    end

    private def next_char : Char
      @reader.next_char
    end

    private def current_pos : Int32
      @reader.pos
    end

    private def read_string_from(start : Int32) : String
      @pool.get Slice.new(@reader.string.to_unsafe + start, @reader.pos - start)
    end

    private def lex_space : Token
      start = current_pos

      while current_char == ' '
        next_char
      end

      Token.new :space, read_string_from start
    end

    private def lex_newline : Token
      start = current_pos

      loop do
        case next_char
        when '\r'
          raise "expected '\n' after '\r'" unless next_char == '\n'
        when '\n'
          next
        else
          break
        end
      end

      Token.new :newline, read_string_from start
    end

    private def lex_ident : Token
      start = current_pos

      while current_char.alphanumeric? || current_char == '_'
        next_char
      end

      case value = read_string_from start
      when "set"
        Token.new :set
      when "to"
        Token.new :to
      else
        Token.new :ident, value
      end
    end

    private def lex_string : Token
      next_char
      start = current_pos

      # TODO: handle escape codes
      loop do
        case current_char
        when '\0'
          raise "unterminated quote string"
        when '"'
          break
        else
          next_char
        end
      end

      value = read_string_from start
      next_char

      Token.new :string, value
    end

    private def lex_number : Token
      start = current_pos
      float = false

      loop do
        case next_char
        when '_', .ascii_number?
          next
        when '.'
          raise "unexpected character '.'" if float
          float = true
        else
          break
        end
      end

      kind = float ? Token::Kind::Float : Token::Kind::Integer

      Token.new kind, read_string_from start
    end
  end
end
