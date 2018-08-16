# 21 -> 20
with open("source/app.d") as f:
    c = f.readlines()
    assert c[21].startswith("//")
    c[21] = c[21][2:]
    c[20] = "//" + c[20]
with open("source/app.d", "w") as f:
    f.write("".join(c))