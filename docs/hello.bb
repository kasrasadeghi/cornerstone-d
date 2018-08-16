(str-table (0 "Hello World\00"))

(decl puts (types i8*) i32)

(def main params i32
  (do 
    (let %result (call puts (types i8*) i32 (args (str-get 0))))
    (return-value 0 i32)))