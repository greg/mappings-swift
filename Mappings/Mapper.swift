//
//  Mapper.swift
//  Mappings
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Greg Omelaenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

public final class Mapper {

    private enum State {
        case Encoding(Encoder)
        case Decoding(Decoder, values: Dictionary<String, Void -> Any?>)
    }

    private let state: State

    init(decoder: Decoder, valueMap: Dictionary<String, Void -> Any?>) {
        state = .Decoding(decoder, values: valueMap)
    }

    init(encoder: Encoder) {
        state = .Encoding(encoder)
    }

    private func decodeForKey<T>(key: String, decoder: Decoder, values: Dictionary<String, Void -> Any?>) -> T? {
        if let decode = values[key] {
            return decode() as! T?
        }
        return decoder.decodeForKey(key)
    }

    public func map<T>(inout v: T, forKey key: String) {
        switch state {
        case .Encoding(let enc):
            enc.encode(v, forKey: key)
        case .Decoding(let dec, let values):
            guard let vv: T = decodeForKey(key, decoder: dec, values: values) else {
                // TODO: do something more sensible
                fatalError()
            }
            v = vv
        }
    }

    public func map<T>(inout v: T!, forKey key: String) {
        var t = v as Optional
        map(&t, forKey: key)
        v = t
    }

    public func map<T>(inout v: T?, forKey key: String) {
        switch state {
        case .Encoding(let enc):
            if let v = v {
                enc.encode(v, forKey: key)
            }
        case .Decoding(let dec, let values):
            v = decodeForKey(key, decoder: dec, values: values)
        }
    }

}