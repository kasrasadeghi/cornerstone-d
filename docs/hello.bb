(str-table
  (0 "Hello World\00"))

(decl puts (type i8*) i32)

(def main params i32
  (do 
    (call puts (types i8*) i32 (args (str-get 0)))
    (return-void)))