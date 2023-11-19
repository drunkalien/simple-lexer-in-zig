pub const Token = struct {
    const Self = @This();

    literal: []const u8,
    token_type: TokenType,

    pub fn new(token_type: TokenType, literal: []const u8) Self {
        const token = Token{ .token_type = token_type, .literal = literal };

        return token;
    }
};

pub const TokenType = enum {
    Illegal,
    Eof,
    Ident,
    Int,
    Assign,
    Plus,
    Comma,
    Semicolon,
    LParen,
    RParen,
    LBrace,
    RBrace,
    Function,
    Let,
    Equal,
    Return,
    True,
    False,
    Minus,
    Bang,
    BangEqual,
    Asterisk,
    Slash,
    LessThan,
    GreaterThan,
    If,
    Else,
    String,
};
