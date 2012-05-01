#include "yygrammar.h"

YYSTART ()
{
   switch(yyselect()) {
   case 35: {
      root();
      get_lexval();
      } break;
   }
}

root ()
{
   switch(yyselect()) {
   case 1: {
      B();
      get_lexval();
      } break;
   }
}

A ()
{
   switch(yyselect()) {
   case 2: {
      C();
      D();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 3: {
      get_lexval();
      get_lexval();
      F();
      B();
      } break;
   case 4: {
      get_lexval();
      C();
      get_lexval();
      F();
      get_lexval();
      D();
      } break;
   case 5: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 6: {
      get_lexval();
      } break;
   }
}

B ()
{
   switch(yyselect()) {
   case 7: {
      E();
      G();
      G();
      F();
      } break;
   }
}

C ()
{
   switch(yyselect()) {
   case 8: {
      A();
      B();
      get_lexval();
      get_lexval();
      F();
      H();
      A();
      } break;
   case 9: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 10: {
      get_lexval();
      C();
      get_lexval();
      } break;
   case 11: {
      E();
      get_lexval();
      get_lexval();
      D();
      } break;
   case 12: {
      get_lexval();
      get_lexval();
      } break;
   }
}

D ()
{
   switch(yyselect()) {
   case 13: {
      A();
      G();
      C();
      C();
      D();
      } break;
   case 14: {
      get_lexval();
      H();
      get_lexval();
      A();
      get_lexval();
      get_lexval();
      } break;
   case 15: {
      get_lexval();
      get_lexval();
      E();
      C();
      get_lexval();
      } break;
   case 16: {
      get_lexval();
      E();
      D();
      get_lexval();
      get_lexval();
      G();
      } break;
   case 17: {
      get_lexval();
      } break;
   }
}

E ()
{
   switch(yyselect()) {
   case 18: {
      get_lexval();
      } break;
   case 19: {
      get_lexval();
      F();
      get_lexval();
      D();
      } break;
   case 20: {
      B();
      } break;
   case 21: {
      get_lexval();
      get_lexval();
      G();
      B();
      F();
      } break;
   case 22: {
      get_lexval();
      get_lexval();
      G();
      H();
      get_lexval();
      } break;
   }
}

F ()
{
   switch(yyselect()) {
   case 23: {
      get_lexval();
      } break;
   case 24: {
      get_lexval();
      C();
      get_lexval();
      get_lexval();
      } break;
   }
}

G ()
{
   switch(yyselect()) {
   case 25: {
      get_lexval();
      get_lexval();
      get_lexval();
      A();
      } break;
   case 26: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 27: {
      get_lexval();
      get_lexval();
      get_lexval();
      H();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 28: {
      B();
      get_lexval();
      get_lexval();
      get_lexval();
      E();
      get_lexval();
      get_lexval();
      } break;
   }
}

H ()
{
   switch(yyselect()) {
   case 29: {
      D();
      get_lexval();
      } break;
   case 30: {
      get_lexval();
      A();
      get_lexval();
      B();
      } break;
   case 31: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 32: {
      F();
      G();
      get_lexval();
      H();
      get_lexval();
      } break;
   case 33: {
      C();
      E();
      get_lexval();
      A();
      } break;
   case 34: {
      get_lexval();
      get_lexval();
      get_lexval();
      B();
      get_lexval();
      get_lexval();
      } break;
   }
}

extern YYSTYPE yylval;
YYSTYPE yylval;
extern long yypos;
long yypos = 1;
/* GentleFlag = no */

typedef struct LEXELEMSTRUCT {
   YYSTYPE val;
   long pos;
   long sym;
   char * text;
   struct LEXELEMSTRUCT *next;
} LEXELEM;
   
LEXELEM *first_lexelem, *cur_lexelem;

init_lexelem()
{
   cur_lexelem = first_lexelem;
}

first_lexval () {
   LEXELEM *p;
   p = (LEXELEM *)malloc(sizeof(LEXELEM));
   if (! p) yymallocerror();
   p->val = yylval;
   p->pos = yypos;
   p->next = 0;
   cur_lexelem = p;
   first_lexelem = p;
}

next_lexval() {
   LEXELEM *p;
   p = (LEXELEM *)malloc(sizeof(LEXELEM));
   if (! p) yymallocerror();
   cur_lexelem-> next = p;
   p->val = yylval;
   p->pos = yypos;
   p->next = 0;
   cur_lexelem = p;
}

get_lexval() {
   extern int FREE_LEXELEMS;
   LEXELEM *p;
   yylval = cur_lexelem->val;
   yypos = cur_lexelem->pos;
   p = cur_lexelem;
   cur_lexelem = cur_lexelem->next;
   free(p);
}

extern int c_length;
int c_length = 251;
extern int yygrammar[];
int yygrammar[] = {
0,
/* 1 */ 0,
/* 2 */ 6,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 35,
/* 6 */ 0,
/* 7 */ 46,
/* 8 */ 50098,
/* 9 */ -6,
/* 10 */ 1,
/* 11 */ 19,
/* 12 */ 53,
/* 13 */ 91,
/* 14 */ 50100,
/* 15 */ 50102,
/* 16 */ 50100,
/* 17 */ -11,
/* 18 */ 2,
/* 19 */ 26,
/* 20 */ 50102,
/* 21 */ 50103,
/* 22 */ 160,
/* 23 */ 46,
/* 24 */ -11,
/* 25 */ 3,
/* 26 */ 35,
/* 27 */ 50097,
/* 28 */ 53,
/* 29 */ 50104,
/* 30 */ 160,
/* 31 */ 50101,
/* 32 */ 91,
/* 33 */ -11,
/* 34 */ 4,
/* 35 */ 42,
/* 36 */ 50104,
/* 37 */ 50101,
/* 38 */ 50097,
/* 39 */ 50099,
/* 40 */ -11,
/* 41 */ 5,
/* 42 */ 0,
/* 43 */ 50097,
/* 44 */ -11,
/* 45 */ 6,
/* 46 */ 0,
/* 47 */ 129,
/* 48 */ 171,
/* 49 */ 171,
/* 50 */ 160,
/* 51 */ -46,
/* 52 */ 7,
/* 53 */ 63,
/* 54 */ 11,
/* 55 */ 46,
/* 56 */ 50100,
/* 57 */ 50101,
/* 58 */ 160,
/* 59 */ 206,
/* 60 */ 11,
/* 61 */ -53,
/* 62 */ 8,
/* 63 */ 73,
/* 64 */ 50100,
/* 65 */ 50104,
/* 66 */ 50100,
/* 67 */ 50103,
/* 68 */ 50101,
/* 69 */ 50103,
/* 70 */ 50098,
/* 71 */ -53,
/* 72 */ 9,
/* 73 */ 79,
/* 74 */ 50099,
/* 75 */ 53,
/* 76 */ 50099,
/* 77 */ -53,
/* 78 */ 10,
/* 79 */ 86,
/* 80 */ 129,
/* 81 */ 50097,
/* 82 */ 50099,
/* 83 */ 91,
/* 84 */ -53,
/* 85 */ 11,
/* 86 */ 0,
/* 87 */ 50103,
/* 88 */ 50102,
/* 89 */ -53,
/* 90 */ 12,
/* 91 */ 99,
/* 92 */ 11,
/* 93 */ 171,
/* 94 */ 53,
/* 95 */ 53,
/* 96 */ 91,
/* 97 */ -91,
/* 98 */ 13,
/* 99 */ 108,
/* 100 */ 50104,
/* 101 */ 206,
/* 102 */ 50098,
/* 103 */ 11,
/* 104 */ 50104,
/* 105 */ 50097,
/* 106 */ -91,
/* 107 */ 14,
/* 108 */ 116,
/* 109 */ 50098,
/* 110 */ 50101,
/* 111 */ 129,
/* 112 */ 53,
/* 113 */ 50099,
/* 114 */ -91,
/* 115 */ 15,
/* 116 */ 125,
/* 117 */ 50102,
/* 118 */ 129,
/* 119 */ 91,
/* 120 */ 50098,
/* 121 */ 50100,
/* 122 */ 171,
/* 123 */ -91,
/* 124 */ 16,
/* 125 */ 0,
/* 126 */ 50099,
/* 127 */ -91,
/* 128 */ 17,
/* 129 */ 133,
/* 130 */ 50102,
/* 131 */ -129,
/* 132 */ 18,
/* 133 */ 140,
/* 134 */ 50103,
/* 135 */ 160,
/* 136 */ 50099,
/* 137 */ 91,
/* 138 */ -129,
/* 139 */ 19,
/* 140 */ 144,
/* 141 */ 46,
/* 142 */ -129,
/* 143 */ 20,
/* 144 */ 152,
/* 145 */ 50101,
/* 146 */ 50100,
/* 147 */ 171,
/* 148 */ 46,
/* 149 */ 160,
/* 150 */ -129,
/* 151 */ 21,
/* 152 */ 0,
/* 153 */ 50099,
/* 154 */ 50099,
/* 155 */ 171,
/* 156 */ 206,
/* 157 */ 50103,
/* 158 */ -129,
/* 159 */ 22,
/* 160 */ 164,
/* 161 */ 50099,
/* 162 */ -160,
/* 163 */ 23,
/* 164 */ 0,
/* 165 */ 50101,
/* 166 */ 53,
/* 167 */ 50100,
/* 168 */ 50099,
/* 169 */ -160,
/* 170 */ 24,
/* 171 */ 178,
/* 172 */ 50098,
/* 173 */ 50102,
/* 174 */ 50103,
/* 175 */ 11,
/* 176 */ -171,
/* 177 */ 25,
/* 178 */ 186,
/* 179 */ 50097,
/* 180 */ 50104,
/* 181 */ 50099,
/* 182 */ 50097,
/* 183 */ 50099,
/* 184 */ -171,
/* 185 */ 26,
/* 186 */ 196,
/* 187 */ 50103,
/* 188 */ 50101,
/* 189 */ 50103,
/* 190 */ 206,
/* 191 */ 50103,
/* 192 */ 50101,
/* 193 */ 50098,
/* 194 */ -171,
/* 195 */ 27,
/* 196 */ 0,
/* 197 */ 46,
/* 198 */ 50098,
/* 199 */ 50099,
/* 200 */ 50100,
/* 201 */ 129,
/* 202 */ 50101,
/* 203 */ 50103,
/* 204 */ -171,
/* 205 */ 28,
/* 206 */ 211,
/* 207 */ 91,
/* 208 */ 50098,
/* 209 */ -206,
/* 210 */ 29,
/* 211 */ 218,
/* 212 */ 50100,
/* 213 */ 11,
/* 214 */ 50104,
/* 215 */ 46,
/* 216 */ -206,
/* 217 */ 30,
/* 218 */ 228,
/* 219 */ 50099,
/* 220 */ 50100,
/* 221 */ 50098,
/* 222 */ 50097,
/* 223 */ 50097,
/* 224 */ 50104,
/* 225 */ 50100,
/* 226 */ -206,
/* 227 */ 31,
/* 228 */ 236,
/* 229 */ 160,
/* 230 */ 171,
/* 231 */ 50104,
/* 232 */ 206,
/* 233 */ 50099,
/* 234 */ -206,
/* 235 */ 32,
/* 236 */ 243,
/* 237 */ 53,
/* 238 */ 129,
/* 239 */ 50102,
/* 240 */ 11,
/* 241 */ -206,
/* 242 */ 33,
/* 243 */ 0,
/* 244 */ 50103,
/* 245 */ 50104,
/* 246 */ 50102,
/* 247 */ 46,
/* 248 */ 50101,
/* 249 */ 50097,
/* 250 */ -206,
/* 251 */ 34,
0
};
extern int yyannotation[];
int yyannotation[] = {
0,
/* 1 */ 0,
/* 2 */ 0,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 0,
/* 6 */ 0,
/* 7 */ 0,
/* 8 */ 50098,
/* 9 */ -6,
/* 10 */ -1,
/* 11 */ 19,
/* 12 */ 0,
/* 13 */ 0,
/* 14 */ 50100,
/* 15 */ 50102,
/* 16 */ 50100,
/* 17 */ -11,
/* 18 */ -1,
/* 19 */ 26,
/* 20 */ 50102,
/* 21 */ 50103,
/* 22 */ 0,
/* 23 */ 0,
/* 24 */ -11,
/* 25 */ -1,
/* 26 */ 35,
/* 27 */ 50097,
/* 28 */ 0,
/* 29 */ 50104,
/* 30 */ 0,
/* 31 */ 50101,
/* 32 */ 0,
/* 33 */ -11,
/* 34 */ -1,
/* 35 */ 42,
/* 36 */ 50104,
/* 37 */ 50101,
/* 38 */ 50097,
/* 39 */ 50099,
/* 40 */ -11,
/* 41 */ -1,
/* 42 */ 0,
/* 43 */ 50097,
/* 44 */ -11,
/* 45 */ -1,
/* 46 */ 0,
/* 47 */ 0,
/* 48 */ 0,
/* 49 */ 0,
/* 50 */ 0,
/* 51 */ -46,
/* 52 */ -1,
/* 53 */ 63,
/* 54 */ 0,
/* 55 */ 0,
/* 56 */ 50100,
/* 57 */ 50101,
/* 58 */ 0,
/* 59 */ 0,
/* 60 */ 0,
/* 61 */ -53,
/* 62 */ -1,
/* 63 */ 73,
/* 64 */ 50100,
/* 65 */ 50104,
/* 66 */ 50100,
/* 67 */ 50103,
/* 68 */ 50101,
/* 69 */ 50103,
/* 70 */ 50098,
/* 71 */ -53,
/* 72 */ -1,
/* 73 */ 79,
/* 74 */ 50099,
/* 75 */ 0,
/* 76 */ 50099,
/* 77 */ -53,
/* 78 */ -1,
/* 79 */ 86,
/* 80 */ 0,
/* 81 */ 50097,
/* 82 */ 50099,
/* 83 */ 0,
/* 84 */ -53,
/* 85 */ -1,
/* 86 */ 0,
/* 87 */ 50103,
/* 88 */ 50102,
/* 89 */ -53,
/* 90 */ -1,
/* 91 */ 99,
/* 92 */ 0,
/* 93 */ 0,
/* 94 */ 0,
/* 95 */ 0,
/* 96 */ 0,
/* 97 */ -91,
/* 98 */ -1,
/* 99 */ 108,
/* 100 */ 50104,
/* 101 */ 0,
/* 102 */ 50098,
/* 103 */ 0,
/* 104 */ 50104,
/* 105 */ 50097,
/* 106 */ -91,
/* 107 */ -1,
/* 108 */ 116,
/* 109 */ 50098,
/* 110 */ 50101,
/* 111 */ 0,
/* 112 */ 0,
/* 113 */ 50099,
/* 114 */ -91,
/* 115 */ -1,
/* 116 */ 125,
/* 117 */ 50102,
/* 118 */ 0,
/* 119 */ 0,
/* 120 */ 50098,
/* 121 */ 50100,
/* 122 */ 0,
/* 123 */ -91,
/* 124 */ -1,
/* 125 */ 0,
/* 126 */ 50099,
/* 127 */ -91,
/* 128 */ -1,
/* 129 */ 133,
/* 130 */ 50102,
/* 131 */ -129,
/* 132 */ -1,
/* 133 */ 140,
/* 134 */ 50103,
/* 135 */ 0,
/* 136 */ 50099,
/* 137 */ 0,
/* 138 */ -129,
/* 139 */ -1,
/* 140 */ 144,
/* 141 */ 0,
/* 142 */ -129,
/* 143 */ -1,
/* 144 */ 152,
/* 145 */ 50101,
/* 146 */ 50100,
/* 147 */ 0,
/* 148 */ 0,
/* 149 */ 0,
/* 150 */ -129,
/* 151 */ -1,
/* 152 */ 0,
/* 153 */ 50099,
/* 154 */ 50099,
/* 155 */ 0,
/* 156 */ 0,
/* 157 */ 50103,
/* 158 */ -129,
/* 159 */ -1,
/* 160 */ 164,
/* 161 */ 50099,
/* 162 */ -160,
/* 163 */ -1,
/* 164 */ 0,
/* 165 */ 50101,
/* 166 */ 0,
/* 167 */ 50100,
/* 168 */ 50099,
/* 169 */ -160,
/* 170 */ -1,
/* 171 */ 178,
/* 172 */ 50098,
/* 173 */ 50102,
/* 174 */ 50103,
/* 175 */ 0,
/* 176 */ -171,
/* 177 */ -1,
/* 178 */ 186,
/* 179 */ 50097,
/* 180 */ 50104,
/* 181 */ 50099,
/* 182 */ 50097,
/* 183 */ 50099,
/* 184 */ -171,
/* 185 */ -1,
/* 186 */ 196,
/* 187 */ 50103,
/* 188 */ 50101,
/* 189 */ 50103,
/* 190 */ 0,
/* 191 */ 50103,
/* 192 */ 50101,
/* 193 */ 50098,
/* 194 */ -171,
/* 195 */ -1,
/* 196 */ 0,
/* 197 */ 0,
/* 198 */ 50098,
/* 199 */ 50099,
/* 200 */ 50100,
/* 201 */ 0,
/* 202 */ 50101,
/* 203 */ 50103,
/* 204 */ -171,
/* 205 */ -1,
/* 206 */ 211,
/* 207 */ 0,
/* 208 */ 50098,
/* 209 */ -206,
/* 210 */ -1,
/* 211 */ 218,
/* 212 */ 50100,
/* 213 */ 0,
/* 214 */ 50104,
/* 215 */ 0,
/* 216 */ -206,
/* 217 */ -1,
/* 218 */ 228,
/* 219 */ 50099,
/* 220 */ 50100,
/* 221 */ 50098,
/* 222 */ 50097,
/* 223 */ 50097,
/* 224 */ 50104,
/* 225 */ 50100,
/* 226 */ -206,
/* 227 */ -1,
/* 228 */ 236,
/* 229 */ 0,
/* 230 */ 0,
/* 231 */ 50104,
/* 232 */ 0,
/* 233 */ 50099,
/* 234 */ -206,
/* 235 */ -1,
/* 236 */ 243,
/* 237 */ 0,
/* 238 */ 0,
/* 239 */ 50102,
/* 240 */ 0,
/* 241 */ -206,
/* 242 */ -1,
/* 243 */ 0,
/* 244 */ 50103,
/* 245 */ 50104,
/* 246 */ 50102,
/* 247 */ 0,
/* 248 */ 50101,
/* 249 */ 50097,
/* 250 */ -206,
/* 251 */ -1,
0
};
extern int yycoordinate[];
int yycoordinate[] = {
0,
/* 1 */ 9999,
/* 2 */ 3006,
/* 3 */ 9999,
/* 4 */ 9999,
/* 5 */ 3006,
/* 6 */ 9999,
/* 7 */ 3008,
/* 8 */ 9999,
/* 9 */ 9999,
/* 10 */ 3008,
/* 11 */ 9999,
/* 12 */ 5005,
/* 13 */ 5007,
/* 14 */ 9999,
/* 15 */ 9999,
/* 16 */ 9999,
/* 17 */ 9999,
/* 18 */ 5005,
/* 19 */ 9999,
/* 20 */ 9999,
/* 21 */ 9999,
/* 22 */ 5032,
/* 23 */ 5034,
/* 24 */ 9999,
/* 25 */ 5024,
/* 26 */ 9999,
/* 27 */ 9999,
/* 28 */ 5043,
/* 29 */ 9999,
/* 30 */ 5049,
/* 31 */ 9999,
/* 32 */ 5055,
/* 33 */ 9999,
/* 34 */ 5039,
/* 35 */ 9999,
/* 36 */ 9999,
/* 37 */ 9999,
/* 38 */ 9999,
/* 39 */ 9999,
/* 40 */ 9999,
/* 41 */ 5060,
/* 42 */ 9999,
/* 43 */ 9999,
/* 44 */ 9999,
/* 45 */ 5079,
/* 46 */ 9999,
/* 47 */ 7005,
/* 48 */ 7007,
/* 49 */ 7009,
/* 50 */ 7011,
/* 51 */ 9999,
/* 52 */ 7005,
/* 53 */ 9999,
/* 54 */ 9005,
/* 55 */ 9007,
/* 56 */ 9999,
/* 57 */ 9999,
/* 58 */ 9017,
/* 59 */ 9019,
/* 60 */ 9021,
/* 61 */ 9999,
/* 62 */ 9005,
/* 63 */ 9999,
/* 64 */ 9999,
/* 65 */ 9999,
/* 66 */ 9999,
/* 67 */ 9999,
/* 68 */ 9999,
/* 69 */ 9999,
/* 70 */ 9999,
/* 71 */ 9999,
/* 72 */ 9026,
/* 73 */ 9999,
/* 74 */ 9999,
/* 75 */ 9061,
/* 76 */ 9999,
/* 77 */ 9999,
/* 78 */ 9057,
/* 79 */ 9999,
/* 80 */ 9070,
/* 81 */ 9999,
/* 82 */ 9999,
/* 83 */ 9080,
/* 84 */ 9999,
/* 85 */ 9070,
/* 86 */ 9999,
/* 87 */ 9999,
/* 88 */ 9999,
/* 89 */ 9999,
/* 90 */ 9085,
/* 91 */ 9999,
/* 92 */ 11005,
/* 93 */ 11007,
/* 94 */ 11009,
/* 95 */ 11011,
/* 96 */ 11013,
/* 97 */ 9999,
/* 98 */ 11005,
/* 99 */ 9999,
/* 100 */ 9999,
/* 101 */ 11022,
/* 102 */ 9999,
/* 103 */ 11028,
/* 104 */ 9999,
/* 105 */ 9999,
/* 106 */ 9999,
/* 107 */ 11018,
/* 108 */ 9999,
/* 109 */ 9999,
/* 110 */ 9999,
/* 111 */ 11049,
/* 112 */ 11051,
/* 113 */ 9999,
/* 114 */ 9999,
/* 115 */ 11041,
/* 116 */ 9999,
/* 117 */ 9999,
/* 118 */ 11064,
/* 119 */ 11066,
/* 120 */ 9999,
/* 121 */ 9999,
/* 122 */ 11076,
/* 123 */ 9999,
/* 124 */ 11060,
/* 125 */ 9999,
/* 126 */ 9999,
/* 127 */ 9999,
/* 128 */ 11081,
/* 129 */ 9999,
/* 130 */ 9999,
/* 131 */ 9999,
/* 132 */ 13005,
/* 133 */ 9999,
/* 134 */ 9999,
/* 135 */ 13016,
/* 136 */ 9999,
/* 137 */ 13022,
/* 138 */ 9999,
/* 139 */ 13012,
/* 140 */ 9999,
/* 141 */ 13027,
/* 142 */ 9999,
/* 143 */ 13027,
/* 144 */ 9999,
/* 145 */ 9999,
/* 146 */ 9999,
/* 147 */ 13040,
/* 148 */ 13042,
/* 149 */ 13044,
/* 150 */ 9999,
/* 151 */ 13032,
/* 152 */ 9999,
/* 153 */ 9999,
/* 154 */ 9999,
/* 155 */ 13057,
/* 156 */ 13059,
/* 157 */ 9999,
/* 158 */ 9999,
/* 159 */ 13049,
/* 160 */ 9999,
/* 161 */ 9999,
/* 162 */ 9999,
/* 163 */ 15005,
/* 164 */ 9999,
/* 165 */ 9999,
/* 166 */ 15016,
/* 167 */ 9999,
/* 168 */ 9999,
/* 169 */ 9999,
/* 170 */ 15012,
/* 171 */ 9999,
/* 172 */ 9999,
/* 173 */ 9999,
/* 174 */ 9999,
/* 175 */ 17017,
/* 176 */ 9999,
/* 177 */ 17005,
/* 178 */ 9999,
/* 179 */ 9999,
/* 180 */ 9999,
/* 181 */ 9999,
/* 182 */ 9999,
/* 183 */ 9999,
/* 184 */ 9999,
/* 185 */ 17022,
/* 186 */ 9999,
/* 187 */ 9999,
/* 188 */ 9999,
/* 189 */ 9999,
/* 190 */ 17057,
/* 191 */ 9999,
/* 192 */ 9999,
/* 193 */ 9999,
/* 194 */ 9999,
/* 195 */ 17045,
/* 196 */ 9999,
/* 197 */ 17074,
/* 198 */ 9999,
/* 199 */ 9999,
/* 200 */ 9999,
/* 201 */ 17088,
/* 202 */ 9999,
/* 203 */ 9999,
/* 204 */ 9999,
/* 205 */ 17074,
/* 206 */ 9999,
/* 207 */ 19005,
/* 208 */ 9999,
/* 209 */ 9999,
/* 210 */ 19005,
/* 211 */ 9999,
/* 212 */ 9999,
/* 213 */ 19018,
/* 214 */ 9999,
/* 215 */ 19024,
/* 216 */ 9999,
/* 217 */ 19014,
/* 218 */ 9999,
/* 219 */ 9999,
/* 220 */ 9999,
/* 221 */ 9999,
/* 222 */ 9999,
/* 223 */ 9999,
/* 224 */ 9999,
/* 225 */ 9999,
/* 226 */ 9999,
/* 227 */ 19029,
/* 228 */ 9999,
/* 229 */ 19060,
/* 230 */ 19062,
/* 231 */ 9999,
/* 232 */ 19068,
/* 233 */ 9999,
/* 234 */ 9999,
/* 235 */ 19060,
/* 236 */ 9999,
/* 237 */ 19077,
/* 238 */ 19079,
/* 239 */ 9999,
/* 240 */ 19085,
/* 241 */ 9999,
/* 242 */ 19077,
/* 243 */ 9999,
/* 244 */ 9999,
/* 245 */ 9999,
/* 246 */ 9999,
/* 247 */ 19102,
/* 248 */ 9999,
/* 249 */ 9999,
/* 250 */ 9999,
/* 251 */ 19090,
0
};
/* only for BIGHASH (see art.c)
extern int DHITS[];
int DHITS[253];
*/
int TABLE[36][256];
init_dirsets() {
TABLE[35][102] = 1;
TABLE[35][103] = 1;
TABLE[35][101] = 1;
TABLE[35][99] = 1;
TABLE[1][99] = 1;
TABLE[1][101] = 1;
TABLE[1][103] = 1;
TABLE[1][102] = 1;
TABLE[2][104] = 1;
TABLE[2][97] = 1;
TABLE[2][102] = 1;
TABLE[2][100] = 1;
TABLE[2][99] = 1;
TABLE[2][103] = 1;
TABLE[2][101] = 1;
TABLE[3][102] = 1;
TABLE[4][97] = 1;
TABLE[5][104] = 1;
TABLE[6][97] = 1;
TABLE[7][102] = 1;
TABLE[7][103] = 1;
TABLE[7][101] = 1;
TABLE[7][99] = 1;
TABLE[8][102] = 1;
TABLE[8][97] = 1;
TABLE[8][104] = 1;
TABLE[8][103] = 1;
TABLE[8][99] = 1;
TABLE[8][100] = 1;
TABLE[8][101] = 1;
TABLE[9][100] = 1;
TABLE[10][99] = 1;
TABLE[11][102] = 1;
TABLE[11][103] = 1;
TABLE[11][101] = 1;
TABLE[11][99] = 1;
TABLE[12][103] = 1;
TABLE[13][102] = 1;
TABLE[13][97] = 1;
TABLE[13][104] = 1;
TABLE[13][103] = 1;
TABLE[13][99] = 1;
TABLE[13][100] = 1;
TABLE[13][101] = 1;
TABLE[14][104] = 1;
TABLE[15][98] = 1;
TABLE[16][102] = 1;
TABLE[17][99] = 1;
TABLE[18][102] = 1;
TABLE[19][103] = 1;
TABLE[20][99] = 1;
TABLE[20][101] = 1;
TABLE[20][103] = 1;
TABLE[20][102] = 1;
TABLE[21][101] = 1;
TABLE[22][99] = 1;
TABLE[23][99] = 1;
TABLE[24][101] = 1;
TABLE[25][98] = 1;
TABLE[26][97] = 1;
TABLE[27][103] = 1;
TABLE[28][99] = 1;
TABLE[28][101] = 1;
TABLE[28][103] = 1;
TABLE[28][102] = 1;
TABLE[29][104] = 1;
TABLE[29][97] = 1;
TABLE[29][102] = 1;
TABLE[29][98] = 1;
TABLE[29][99] = 1;
TABLE[29][100] = 1;
TABLE[29][103] = 1;
TABLE[29][101] = 1;
TABLE[30][100] = 1;
TABLE[31][99] = 1;
TABLE[32][99] = 1;
TABLE[32][101] = 1;
TABLE[33][104] = 1;
TABLE[33][97] = 1;
TABLE[33][102] = 1;
TABLE[33][100] = 1;
TABLE[33][99] = 1;
TABLE[33][103] = 1;
TABLE[33][101] = 1;
TABLE[34][103] = 1;
}

extern int yydirset();
int yydirset(i,j)
   int i,j;
{
   return TABLE[i][j];
}
int yytransparent(n)
   int n;
{
   switch(n) {
      case 1: return 0; break;
      case 6: return 0; break;
      case 11: return 0; break;
      case 46: return 0; break;
      case 53: return 0; break;
      case 91: return 0; break;
      case 129: return 0; break;
      case 160: return 0; break;
      case 171: return 0; break;
      case 206: return 0; break;
   }
}
char * yyprintname(n)
   int n;
{
   if (n <= 50000)
      switch(n) {
         case 1: return "YYSTART"; break;
         case 6: return "root"; break;
         case 11: return "A"; break;
         case 46: return "B"; break;
         case 53: return "C"; break;
         case 91: return "D"; break;
         case 129: return "E"; break;
         case 160: return "F"; break;
         case 171: return "G"; break;
         case 206: return "H"; break;
   }
   else 
      switch(n-50000) {
      }
   return "special_character";
}