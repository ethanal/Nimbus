def bsd_rand(seed):
    return (1103515245 * seed + 12345) & 0x7fffffff


def baseconv(v1, a1, a2):
    n1 = {c: i for i, c in dict(enumerate(a1)).items()}
    b1 = len(a1)
    b2 = len(a2)

    d1 = 0
    for i, c in enumerate(v1):
        d1 += n1[c] * pow(b1, b1 - i - 1)

    v2 = ""
    while d1:
        v2 = a2[d1 % b2] + v2
        d1 //= b2

    return v2


def url_hash_from_pk(pk):
    b10 = "0123456789"
    b62 = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return baseconv(str(bsd_rand(pk)), b10, b62)
