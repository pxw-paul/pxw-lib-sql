ROUTINE PXW.LIB.SQL.Macros [Type=INC]
#define FIELD(%f) $PIECE(%f,"=",1)
#define VALUE(%f) $PIECE(%f,"=",2)
#define SQLFIELD(%f) $PIECE(%f,'=',1)
#define SQLVALUE(%f) $PIECE(%f,'=',2)