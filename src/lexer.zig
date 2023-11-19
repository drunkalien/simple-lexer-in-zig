const token = @import("token.zig");
const std = @import("std");
const isWhitespace = std.ascii.isWhitespace;
const isAlpha = std.ascii.isAlphabetic;
const isDigit = std.ascii.isDigit;

pub const Lexer = struct {
    const Self = @This();
    position: usize,
    read_position: usize,
    ch: u8,
    input: []const u8,

    pub fn new(input: []const u8) Self {
        var l = Self{
            .position = 0,
            .read_position = 0,
            .ch = 0,
            .input = input,
        };

        _ = l.nextToken();

        return l;
    }

    pub fn readChar(self: *Self) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
            return;
        } else {
            self.ch = self.input[self.read_position];
        }

        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn nextToken(self: *Self) token.Token {
        self.skipWhitespace();

        const currToken = switch (self.ch) {
            '=' => token.Token.new(token.TokenType.Assign, "="),
            '+' => token.Token.new(token.TokenType.Plus, "+"),
            ';' => token.Token.new(token.TokenType.Semicolon, ";"),
            '(' => token.Token.new(token.TokenType.LParen, "("),
            ')' => token.Token.new(token.TokenType.RParen, ")"),
            ',' => token.Token.new(token.TokenType.Comma, ","),
            '{' => token.Token.new(token.TokenType.LBrace, "{"),
            '}' => token.Token.new(token.TokenType.RBrace, "}"),
            'a'...'z', 'A'...'Z' => {
                const ident = self.readIdent();

                if (std.mem.eql(u8, "fn", ident)) {
                    return token.Token.new(token.TokenType.Function, "fn");
                } else if (std.mem.eql(u8, "let", ident)) {
                    return token.Token.new(token.TokenType.Let, "let");
                } else if (std.mem.eql(u8, "true", ident)) {
                    return token.Token.new(token.TokenType.True, "true");
                } else if (std.mem.eql(u8, "false", ident)) {
                    return token.Token.new(token.TokenType.False, "false");
                } else if (std.mem.eql(u8, "return", ident)) {
                    return token.Token.new(token.TokenType.Return, "return");
                } else if (std.mem.eql(u8, "if", ident)) {
                    return token.Token.new(token.TokenType.If, "if");
                } else if (std.mem.eql(u8, "else", ident)) {
                    return token.Token.new(token.TokenType.Else, "else");
                } else {
                    return token.Token.new(token.TokenType.Ident, ident);
                }
            },
            '0'...'9' => {
                const number = self.readInt();
                return token.Token.new(token.TokenType.Int, number);
            },
            '-' => token.Token.new(token.TokenType.Minus, "-"),
            '!' => token.Token.new(token.TokenType.Bang, "!"),
            '*' => token.Token.new(token.TokenType.Asterisk, "*"),
            '/' => token.Token.new(token.TokenType.Slash, "/"),
            0 => token.Token.new(token.TokenType.Eof, ""),
            else => token.Token.new(token.TokenType.Illegal, ""),
        };
        self.readChar();
        return currToken;
    }

    fn skipWhitespace(self: *Self) void {
        while (isWhitespace(self.ch)) {
            self.readChar();
        }
    }

    fn readIdent(self: *Self) []const u8 {
        const position = self.position;
        while ((isAlpha(self.ch))) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    fn readInt(self: *Self) []const u8 {
        const position = self.position;
        while (isDigit(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }
};

test "Lexer test" {
    const Test = std.meta.Tuple(&.{ token.TokenType, []const u8 });
    const input = "let five = 5;\nlet ten = 10;\nlet add = fn(x, y) { return x + y; }";

    var lexer = Lexer.new(input);
    const tests = [_]Test{
        .{ token.TokenType.Let, "let" },
        .{ token.TokenType.Ident, "five" },
        .{ token.TokenType.Assign, "=" },
        .{ token.TokenType.Int, "5" },
        .{ token.TokenType.Semicolon, ";" },
        .{ token.TokenType.Let, "let" },
        .{ token.TokenType.Ident, "ten" },
        .{ token.TokenType.Assign, "=" },
        .{ token.TokenType.Int, "10" },
        .{ token.TokenType.Semicolon, ";" },
        .{ token.TokenType.Let, "let" },
        .{ token.TokenType.Ident, "add" },
        .{ token.TokenType.Assign, "=" },
        .{ token.TokenType.Function, "fn" },
        .{ token.TokenType.LParen, "(" },
        .{ token.TokenType.Ident, "x" },
        .{ token.TokenType.Comma, "," },
        .{ token.TokenType.Ident, "y" },
        .{ token.TokenType.RParen, ")" },
        .{ token.TokenType.LBrace, "{" },
        .{ token.TokenType.Return, "return" },
        .{ token.TokenType.Ident, "x" },
        .{ token.TokenType.Plus, "+" },
        .{ token.TokenType.Ident, "y" },
        .{ token.TokenType.Semicolon, ";" },
        .{ token.TokenType.RBrace, "}" },
    };
    for (&tests) |*test_case| {
        const tok = lexer.nextToken();
        try std.testing.expect(tok.token_type == test_case.@"0");
        try std.testing.expect(std.mem.eql(u8, tok.literal, test_case.@"1"));
    }
}
