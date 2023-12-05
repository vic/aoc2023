BEGIN{ fn = "part1.txt"; n = 1; i = 0; }
{
   if (i == 0) {
     if (substr($0,1,3) == "```") {
        i = 1
     }
     next
   } else {
     if (substr($0,1,3) == "```") {
         close (fn)
         n++
         fn = "part" n ".txt"
         i = 0
         next
     } else {
         print > fn
     }
   }
}