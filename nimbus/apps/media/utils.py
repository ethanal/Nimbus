from nimbus.settings import SECRET_KEY 
import hashlib


def baseconv(v1, a1, a2):
    n1 = {c: i for i, c in enumerate(a1)}
    b1 = len(a1)
    b2 = len(a2)

    d1 = 0
    for i, c in enumerate(v1):
        d1 += n1[c] * pow(b1, len(v1) - i - 1)

    v2 = ""
    while d1:
        v2 = a2[d1 % b2] + v2
        d1 //= b2

    return v2


m = hashlib.md5()
m.update(SECRET_KEY)
c = int(baseconv(m.hexdigest(), "0123456789abcdef", "0123456789"))
c = c - (c % 2) + 1


def lcg(seed):
    return (1103515245 * seed + c) & 0x7fffffff


def url_hash_from_pk(pk):
    b10 = "0123456789"
    b62 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    return baseconv(str(lcg(pk)), b10, b62)
