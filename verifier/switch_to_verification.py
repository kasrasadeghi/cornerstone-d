# 20 -> 21
with open("source/app.d") as f:
    c = f.readlines()
    assert c[20].startswith("//")
    c[20] = c[20][2:]
    c[21] = "//" + c[21]
with open("source/app.d", "w") as f:
    f.write("".join(c))