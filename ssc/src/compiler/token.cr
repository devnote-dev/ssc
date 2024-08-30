module SSC
  class Token
    enum Kind
      EOF
      Space
      Newline

      Ident
      String
      Integer
      Float

      Plus
      Minus
      Asterisk
      Slash
      Comma

      Set
      To

      def to_s : ::String
        if self == EOF
          "EOF"
        else
          super.downcase
        end
      end
    end

    getter kind : Kind
    setter value : String?

    def initialize(@kind, @value = nil)
    end

    def value : String
      @value.as(String)
    end

    def pretty_print(pp : PrettyPrint) : Nil
      pp.text "SSC::Token("
      pp.group 1 do
        pp.breakable ""
        pp.text "@kind="
        @kind.pretty_print pp
        pp.comma

        pp.text "@value="
        @value.pretty_print pp
      end
      pp.text ")"
    end
  end
end
