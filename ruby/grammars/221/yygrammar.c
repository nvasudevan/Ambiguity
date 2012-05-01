#include "yygrammar.h"

YYSTART ()
{
   switch(yyselect()) {
   case 39: {
      root();
      get_lexval();
      } break;
   }
}

root ()
{
   switch(yyselect()) {
   case 1: {
      E();
      C();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 2: {
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 3: {
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 4: {
      D();
      H();
      get_lexval();
      } break;
   case 5: {
      get_lexval();
      E();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 6: {
      get_lexval();
      get_lexval();
      H();
      get_lexval();
      get_lexval();
      } break;
   }
}

A ()
{
   switch(yyselect()) {
   case 7: {
      B();
      } break;
   case 8: {
      C();
      E();
      } break;
   case 9: {
      get_lexval();
      G();
      } break;
   case 10: {
      get_lexval();
      get_lexval();
      } break;
   case 11: {
      D();
      C();
      get_lexval();
      } break;
   }
}

B ()
{
   switch(yyselect()) {
   case 12: {
      D();
      get_lexval();
      } break;
   case 13: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      F();
      } break;
   case 14: {
      A();
      G();
      F();
      A();
      A();
      get_lexval();
      C();
      } break;
   }
}

C ()
{
   switch(yyselect()) {
   case 15: {
      G();
      get_lexval();
      B();
      } break;
   case 16: {
      D();
      A();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 17: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 18: {
      B();
      get_lexval();
      } break;
   }
}

D ()
{
   switch(yyselect()) {
   case 19: {
      get_lexval();
      F();
      } break;
   case 20: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 21: {
      H();
      G();
      get_lexval();
      H();
      F();
      } break;
   case 22: {
      get_lexval();
      get_lexval();
      get_lexval();
      D();
      get_lexval();
      } break;
   }
}

E ()
{
   switch(yyselect()) {
   case 23: {
      get_lexval();
      get_lexval();
      E();
      } break;
   case 24: {
      C();
      get_lexval();
      E();
      A();
      A();
      get_lexval();
      get_lexval();
      } break;
   }
}

F ()
{
   switch(yyselect()) {
   case 25: {
      get_lexval();
      get_lexval();
      get_lexval();
      G();
      } break;
   case 26: {
      get_lexval();
      G();
      } break;
   case 27: {
      get_lexval();
      } break;
   case 28: {
      get_lexval();
      D();
      H();
      get_lexval();
      G();
      get_lexval();
      A();
      } break;
   }
}

G ()
{
   switch(yyselect()) {
   case 29: {
      get_lexval();
      C();
      E();
      get_lexval();
      F();
      A();
      } break;
   case 30: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 31: {
      get_lexval();
      get_lexval();
      D();
      get_lexval();
      get_lexval();
      H();
      } break;
   }
}

H ()
{
   switch(yyselect()) {
   case 32: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 33: {
      G();
      } break;
   case 34: {
      F();
      } break;
   case 35: {
      get_lexval();
      B();
      C();
      get_lexval();
      get_lexval();
      } break;
   case 36: {
      get_lexval();
      } break;
   case 37: {
      get_lexval();
      } break;
   case 38: {
      get_lexval();
      F();
      get_lexval();
      G();
      A();
      get_lexval();
      H();
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
int c_length = 266;
extern int yygrammar[];
int yygrammar[] = {
0,
/* 1 */ 0,
/* 2 */ 6,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 39,
/* 6 */ 14,
/* 7 */ 156,
/* 8 */ 96,
/* 9 */ 50101,
/* 10 */ 50103,
/* 11 */ 50097,
/* 12 */ -6,
/* 13 */ 1,
/* 14 */ 20,
/* 15 */ 50101,
/* 16 */ 50101,
/* 17 */ 50097,
/* 18 */ -6,
/* 19 */ 2,
/* 20 */ 26,
/* 21 */ 50102,
/* 22 */ 50100,
/* 23 */ 50102,
/* 24 */ -6,
/* 25 */ 3,
/* 26 */ 32,
/* 27 */ 125,
/* 28 */ 226,
/* 29 */ 50102,
/* 30 */ -6,
/* 31 */ 4,
/* 32 */ 40,
/* 33 */ 50104,
/* 34 */ 156,
/* 35 */ 50097,
/* 36 */ 50098,
/* 37 */ 50101,
/* 38 */ -6,
/* 39 */ 5,
/* 40 */ 0,
/* 41 */ 50102,
/* 42 */ 50101,
/* 43 */ 226,
/* 44 */ 50103,
/* 45 */ 50103,
/* 46 */ -6,
/* 47 */ 6,
/* 48 */ 52,
/* 49 */ 73,
/* 50 */ -48,
/* 51 */ 7,
/* 52 */ 57,
/* 53 */ 96,
/* 54 */ 156,
/* 55 */ -48,
/* 56 */ 8,
/* 57 */ 62,
/* 58 */ 50101,
/* 59 */ 198,
/* 60 */ -48,
/* 61 */ 9,
/* 62 */ 67,
/* 63 */ 50098,
/* 64 */ 50102,
/* 65 */ -48,
/* 66 */ 10,
/* 67 */ 0,
/* 68 */ 125,
/* 69 */ 96,
/* 70 */ 50103,
/* 71 */ -48,
/* 72 */ 11,
/* 73 */ 78,
/* 74 */ 125,
/* 75 */ 50102,
/* 76 */ -73,
/* 77 */ 12,
/* 78 */ 86,
/* 79 */ 50099,
/* 80 */ 50098,
/* 81 */ 50097,
/* 82 */ 50099,
/* 83 */ 172,
/* 84 */ -73,
/* 85 */ 13,
/* 86 */ 0,
/* 87 */ 48,
/* 88 */ 198,
/* 89 */ 172,
/* 90 */ 48,
/* 91 */ 48,
/* 92 */ 50100,
/* 93 */ 96,
/* 94 */ -73,
/* 95 */ 14,
/* 96 */ 102,
/* 97 */ 198,
/* 98 */ 50099,
/* 99 */ 73,
/* 100 */ -96,
/* 101 */ 15,
/* 102 */ 110,
/* 103 */ 125,
/* 104 */ 48,
/* 105 */ 50098,
/* 106 */ 50101,
/* 107 */ 50099,
/* 108 */ -96,
/* 109 */ 16,
/* 110 */ 120,
/* 111 */ 50103,
/* 112 */ 50097,
/* 113 */ 50104,
/* 114 */ 50104,
/* 115 */ 50101,
/* 116 */ 50101,
/* 117 */ 50097,
/* 118 */ -96,
/* 119 */ 17,
/* 120 */ 0,
/* 121 */ 73,
/* 122 */ 50099,
/* 123 */ -96,
/* 124 */ 18,
/* 125 */ 130,
/* 126 */ 50103,
/* 127 */ 172,
/* 128 */ -125,
/* 129 */ 19,
/* 130 */ 140,
/* 131 */ 50103,
/* 132 */ 50098,
/* 133 */ 50099,
/* 134 */ 50098,
/* 135 */ 50101,
/* 136 */ 50098,
/* 137 */ 50101,
/* 138 */ -125,
/* 139 */ 20,
/* 140 */ 148,
/* 141 */ 226,
/* 142 */ 198,
/* 143 */ 50104,
/* 144 */ 226,
/* 145 */ 172,
/* 146 */ -125,
/* 147 */ 21,
/* 148 */ 0,
/* 149 */ 50104,
/* 150 */ 50098,
/* 151 */ 50097,
/* 152 */ 125,
/* 153 */ 50101,
/* 154 */ -125,
/* 155 */ 22,
/* 156 */ 162,
/* 157 */ 50102,
/* 158 */ 50097,
/* 159 */ 156,
/* 160 */ -156,
/* 161 */ 23,
/* 162 */ 0,
/* 163 */ 96,
/* 164 */ 50099,
/* 165 */ 156,
/* 166 */ 48,
/* 167 */ 48,
/* 168 */ 50103,
/* 169 */ 50100,
/* 170 */ -156,
/* 171 */ 24,
/* 172 */ 179,
/* 173 */ 50102,
/* 174 */ 50102,
/* 175 */ 50098,
/* 176 */ 198,
/* 177 */ -172,
/* 178 */ 25,
/* 179 */ 184,
/* 180 */ 50100,
/* 181 */ 198,
/* 182 */ -172,
/* 183 */ 26,
/* 184 */ 188,
/* 185 */ 50098,
/* 186 */ -172,
/* 187 */ 27,
/* 188 */ 0,
/* 189 */ 50103,
/* 190 */ 125,
/* 191 */ 226,
/* 192 */ 50103,
/* 193 */ 198,
/* 194 */ 50101,
/* 195 */ 48,
/* 196 */ -172,
/* 197 */ 28,
/* 198 */ 207,
/* 199 */ 50104,
/* 200 */ 96,
/* 201 */ 156,
/* 202 */ 50101,
/* 203 */ 172,
/* 204 */ 48,
/* 205 */ -198,
/* 206 */ 29,
/* 207 */ 217,
/* 208 */ 50101,
/* 209 */ 50099,
/* 210 */ 50103,
/* 211 */ 50100,
/* 212 */ 50099,
/* 213 */ 50103,
/* 214 */ 50104,
/* 215 */ -198,
/* 216 */ 30,
/* 217 */ 0,
/* 218 */ 50101,
/* 219 */ 50104,
/* 220 */ 125,
/* 221 */ 50099,
/* 222 */ 50098,
/* 223 */ 226,
/* 224 */ -198,
/* 225 */ 31,
/* 226 */ 233,
/* 227 */ 50097,
/* 228 */ 50102,
/* 229 */ 50099,
/* 230 */ 50099,
/* 231 */ -226,
/* 232 */ 32,
/* 233 */ 237,
/* 234 */ 198,
/* 235 */ -226,
/* 236 */ 33,
/* 237 */ 241,
/* 238 */ 172,
/* 239 */ -226,
/* 240 */ 34,
/* 241 */ 249,
/* 242 */ 50099,
/* 243 */ 73,
/* 244 */ 96,
/* 245 */ 50100,
/* 246 */ 50101,
/* 247 */ -226,
/* 248 */ 35,
/* 249 */ 253,
/* 250 */ 50098,
/* 251 */ -226,
/* 252 */ 36,
/* 253 */ 257,
/* 254 */ 50099,
/* 255 */ -226,
/* 256 */ 37,
/* 257 */ 0,
/* 258 */ 50104,
/* 259 */ 172,
/* 260 */ 50101,
/* 261 */ 198,
/* 262 */ 48,
/* 263 */ 50103,
/* 264 */ 226,
/* 265 */ -226,
/* 266 */ 38,
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
/* 6 */ 14,
/* 7 */ 0,
/* 8 */ 0,
/* 9 */ 50101,
/* 10 */ 50103,
/* 11 */ 50097,
/* 12 */ -6,
/* 13 */ -1,
/* 14 */ 20,
/* 15 */ 50101,
/* 16 */ 50101,
/* 17 */ 50097,
/* 18 */ -6,
/* 19 */ -1,
/* 20 */ 26,
/* 21 */ 50102,
/* 22 */ 50100,
/* 23 */ 50102,
/* 24 */ -6,
/* 25 */ -1,
/* 26 */ 32,
/* 27 */ 0,
/* 28 */ 0,
/* 29 */ 50102,
/* 30 */ -6,
/* 31 */ -1,
/* 32 */ 40,
/* 33 */ 50104,
/* 34 */ 0,
/* 35 */ 50097,
/* 36 */ 50098,
/* 37 */ 50101,
/* 38 */ -6,
/* 39 */ -1,
/* 40 */ 0,
/* 41 */ 50102,
/* 42 */ 50101,
/* 43 */ 0,
/* 44 */ 50103,
/* 45 */ 50103,
/* 46 */ -6,
/* 47 */ -1,
/* 48 */ 52,
/* 49 */ 0,
/* 50 */ -48,
/* 51 */ -1,
/* 52 */ 57,
/* 53 */ 0,
/* 54 */ 0,
/* 55 */ -48,
/* 56 */ -1,
/* 57 */ 62,
/* 58 */ 50101,
/* 59 */ 0,
/* 60 */ -48,
/* 61 */ -1,
/* 62 */ 67,
/* 63 */ 50098,
/* 64 */ 50102,
/* 65 */ -48,
/* 66 */ -1,
/* 67 */ 0,
/* 68 */ 0,
/* 69 */ 0,
/* 70 */ 50103,
/* 71 */ -48,
/* 72 */ -1,
/* 73 */ 78,
/* 74 */ 0,
/* 75 */ 50102,
/* 76 */ -73,
/* 77 */ -1,
/* 78 */ 86,
/* 79 */ 50099,
/* 80 */ 50098,
/* 81 */ 50097,
/* 82 */ 50099,
/* 83 */ 0,
/* 84 */ -73,
/* 85 */ -1,
/* 86 */ 0,
/* 87 */ 0,
/* 88 */ 0,
/* 89 */ 0,
/* 90 */ 0,
/* 91 */ 0,
/* 92 */ 50100,
/* 93 */ 0,
/* 94 */ -73,
/* 95 */ -1,
/* 96 */ 102,
/* 97 */ 0,
/* 98 */ 50099,
/* 99 */ 0,
/* 100 */ -96,
/* 101 */ -1,
/* 102 */ 110,
/* 103 */ 0,
/* 104 */ 0,
/* 105 */ 50098,
/* 106 */ 50101,
/* 107 */ 50099,
/* 108 */ -96,
/* 109 */ -1,
/* 110 */ 120,
/* 111 */ 50103,
/* 112 */ 50097,
/* 113 */ 50104,
/* 114 */ 50104,
/* 115 */ 50101,
/* 116 */ 50101,
/* 117 */ 50097,
/* 118 */ -96,
/* 119 */ -1,
/* 120 */ 0,
/* 121 */ 0,
/* 122 */ 50099,
/* 123 */ -96,
/* 124 */ -1,
/* 125 */ 130,
/* 126 */ 50103,
/* 127 */ 0,
/* 128 */ -125,
/* 129 */ -1,
/* 130 */ 140,
/* 131 */ 50103,
/* 132 */ 50098,
/* 133 */ 50099,
/* 134 */ 50098,
/* 135 */ 50101,
/* 136 */ 50098,
/* 137 */ 50101,
/* 138 */ -125,
/* 139 */ -1,
/* 140 */ 148,
/* 141 */ 0,
/* 142 */ 0,
/* 143 */ 50104,
/* 144 */ 0,
/* 145 */ 0,
/* 146 */ -125,
/* 147 */ -1,
/* 148 */ 0,
/* 149 */ 50104,
/* 150 */ 50098,
/* 151 */ 50097,
/* 152 */ 0,
/* 153 */ 50101,
/* 154 */ -125,
/* 155 */ -1,
/* 156 */ 162,
/* 157 */ 50102,
/* 158 */ 50097,
/* 159 */ 0,
/* 160 */ -156,
/* 161 */ -1,
/* 162 */ 0,
/* 163 */ 0,
/* 164 */ 50099,
/* 165 */ 0,
/* 166 */ 0,
/* 167 */ 0,
/* 168 */ 50103,
/* 169 */ 50100,
/* 170 */ -156,
/* 171 */ -1,
/* 172 */ 179,
/* 173 */ 50102,
/* 174 */ 50102,
/* 175 */ 50098,
/* 176 */ 0,
/* 177 */ -172,
/* 178 */ -1,
/* 179 */ 184,
/* 180 */ 50100,
/* 181 */ 0,
/* 182 */ -172,
/* 183 */ -1,
/* 184 */ 188,
/* 185 */ 50098,
/* 186 */ -172,
/* 187 */ -1,
/* 188 */ 0,
/* 189 */ 50103,
/* 190 */ 0,
/* 191 */ 0,
/* 192 */ 50103,
/* 193 */ 0,
/* 194 */ 50101,
/* 195 */ 0,
/* 196 */ -172,
/* 197 */ -1,
/* 198 */ 207,
/* 199 */ 50104,
/* 200 */ 0,
/* 201 */ 0,
/* 202 */ 50101,
/* 203 */ 0,
/* 204 */ 0,
/* 205 */ -198,
/* 206 */ -1,
/* 207 */ 217,
/* 208 */ 50101,
/* 209 */ 50099,
/* 210 */ 50103,
/* 211 */ 50100,
/* 212 */ 50099,
/* 213 */ 50103,
/* 214 */ 50104,
/* 215 */ -198,
/* 216 */ -1,
/* 217 */ 0,
/* 218 */ 50101,
/* 219 */ 50104,
/* 220 */ 0,
/* 221 */ 50099,
/* 222 */ 50098,
/* 223 */ 0,
/* 224 */ -198,
/* 225 */ -1,
/* 226 */ 233,
/* 227 */ 50097,
/* 228 */ 50102,
/* 229 */ 50099,
/* 230 */ 50099,
/* 231 */ -226,
/* 232 */ -1,
/* 233 */ 237,
/* 234 */ 0,
/* 235 */ -226,
/* 236 */ -1,
/* 237 */ 241,
/* 238 */ 0,
/* 239 */ -226,
/* 240 */ -1,
/* 241 */ 249,
/* 242 */ 50099,
/* 243 */ 0,
/* 244 */ 0,
/* 245 */ 50100,
/* 246 */ 50101,
/* 247 */ -226,
/* 248 */ -1,
/* 249 */ 253,
/* 250 */ 50098,
/* 251 */ -226,
/* 252 */ -1,
/* 253 */ 257,
/* 254 */ 50099,
/* 255 */ -226,
/* 256 */ -1,
/* 257 */ 0,
/* 258 */ 50104,
/* 259 */ 0,
/* 260 */ 50101,
/* 261 */ 0,
/* 262 */ 0,
/* 263 */ 50103,
/* 264 */ 0,
/* 265 */ -226,
/* 266 */ -1,
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
/* 8 */ 3010,
/* 9 */ 9999,
/* 10 */ 9999,
/* 11 */ 9999,
/* 12 */ 9999,
/* 13 */ 3008,
/* 14 */ 9999,
/* 15 */ 9999,
/* 16 */ 9999,
/* 17 */ 9999,
/* 18 */ 9999,
/* 19 */ 3027,
/* 20 */ 9999,
/* 21 */ 9999,
/* 22 */ 9999,
/* 23 */ 9999,
/* 24 */ 9999,
/* 25 */ 3042,
/* 26 */ 9999,
/* 27 */ 3057,
/* 28 */ 3059,
/* 29 */ 9999,
/* 30 */ 9999,
/* 31 */ 3057,
/* 32 */ 9999,
/* 33 */ 9999,
/* 34 */ 3072,
/* 35 */ 9999,
/* 36 */ 9999,
/* 37 */ 9999,
/* 38 */ 9999,
/* 39 */ 3068,
/* 40 */ 9999,
/* 41 */ 9999,
/* 42 */ 9999,
/* 43 */ 3097,
/* 44 */ 9999,
/* 45 */ 9999,
/* 46 */ 9999,
/* 47 */ 3089,
/* 48 */ 9999,
/* 49 */ 5005,
/* 50 */ 9999,
/* 51 */ 5005,
/* 52 */ 9999,
/* 53 */ 5010,
/* 54 */ 5012,
/* 55 */ 9999,
/* 56 */ 5010,
/* 57 */ 9999,
/* 58 */ 9999,
/* 59 */ 5021,
/* 60 */ 9999,
/* 61 */ 5017,
/* 62 */ 9999,
/* 63 */ 9999,
/* 64 */ 9999,
/* 65 */ 9999,
/* 66 */ 5026,
/* 67 */ 9999,
/* 68 */ 5037,
/* 69 */ 5039,
/* 70 */ 9999,
/* 71 */ 9999,
/* 72 */ 5037,
/* 73 */ 9999,
/* 74 */ 7005,
/* 75 */ 9999,
/* 76 */ 9999,
/* 77 */ 7005,
/* 78 */ 9999,
/* 79 */ 9999,
/* 80 */ 9999,
/* 81 */ 9999,
/* 82 */ 9999,
/* 83 */ 7030,
/* 84 */ 9999,
/* 85 */ 7014,
/* 86 */ 9999,
/* 87 */ 7035,
/* 88 */ 7037,
/* 89 */ 7039,
/* 90 */ 7041,
/* 91 */ 7043,
/* 92 */ 9999,
/* 93 */ 7049,
/* 94 */ 9999,
/* 95 */ 7035,
/* 96 */ 9999,
/* 97 */ 9005,
/* 98 */ 9999,
/* 99 */ 9011,
/* 100 */ 9999,
/* 101 */ 9005,
/* 102 */ 9999,
/* 103 */ 9016,
/* 104 */ 9018,
/* 105 */ 9999,
/* 106 */ 9999,
/* 107 */ 9999,
/* 108 */ 9999,
/* 109 */ 9016,
/* 110 */ 9999,
/* 111 */ 9999,
/* 112 */ 9999,
/* 113 */ 9999,
/* 114 */ 9999,
/* 115 */ 9999,
/* 116 */ 9999,
/* 117 */ 9999,
/* 118 */ 9999,
/* 119 */ 9035,
/* 120 */ 9999,
/* 121 */ 9066,
/* 122 */ 9999,
/* 123 */ 9999,
/* 124 */ 9066,
/* 125 */ 9999,
/* 126 */ 9999,
/* 127 */ 11009,
/* 128 */ 9999,
/* 129 */ 11005,
/* 130 */ 9999,
/* 131 */ 9999,
/* 132 */ 9999,
/* 133 */ 9999,
/* 134 */ 9999,
/* 135 */ 9999,
/* 136 */ 9999,
/* 137 */ 9999,
/* 138 */ 9999,
/* 139 */ 11014,
/* 140 */ 9999,
/* 141 */ 11045,
/* 142 */ 11047,
/* 143 */ 9999,
/* 144 */ 11053,
/* 145 */ 11055,
/* 146 */ 9999,
/* 147 */ 11045,
/* 148 */ 9999,
/* 149 */ 9999,
/* 150 */ 9999,
/* 151 */ 9999,
/* 152 */ 11072,
/* 153 */ 9999,
/* 154 */ 9999,
/* 155 */ 11060,
/* 156 */ 9999,
/* 157 */ 9999,
/* 158 */ 9999,
/* 159 */ 13013,
/* 160 */ 9999,
/* 161 */ 13005,
/* 162 */ 9999,
/* 163 */ 13018,
/* 164 */ 9999,
/* 165 */ 13024,
/* 166 */ 13026,
/* 167 */ 13028,
/* 168 */ 9999,
/* 169 */ 9999,
/* 170 */ 9999,
/* 171 */ 13018,
/* 172 */ 9999,
/* 173 */ 9999,
/* 174 */ 9999,
/* 175 */ 9999,
/* 176 */ 15017,
/* 177 */ 9999,
/* 178 */ 15005,
/* 179 */ 9999,
/* 180 */ 9999,
/* 181 */ 15026,
/* 182 */ 9999,
/* 183 */ 15022,
/* 184 */ 9999,
/* 185 */ 9999,
/* 186 */ 9999,
/* 187 */ 15031,
/* 188 */ 9999,
/* 189 */ 9999,
/* 190 */ 15042,
/* 191 */ 15044,
/* 192 */ 9999,
/* 193 */ 15050,
/* 194 */ 9999,
/* 195 */ 15056,
/* 196 */ 9999,
/* 197 */ 15038,
/* 198 */ 9999,
/* 199 */ 9999,
/* 200 */ 17009,
/* 201 */ 17011,
/* 202 */ 9999,
/* 203 */ 17017,
/* 204 */ 17019,
/* 205 */ 9999,
/* 206 */ 17005,
/* 207 */ 9999,
/* 208 */ 9999,
/* 209 */ 9999,
/* 210 */ 9999,
/* 211 */ 9999,
/* 212 */ 9999,
/* 213 */ 9999,
/* 214 */ 9999,
/* 215 */ 9999,
/* 216 */ 17024,
/* 217 */ 9999,
/* 218 */ 9999,
/* 219 */ 9999,
/* 220 */ 17063,
/* 221 */ 9999,
/* 222 */ 9999,
/* 223 */ 17073,
/* 224 */ 9999,
/* 225 */ 17055,
/* 226 */ 9999,
/* 227 */ 9999,
/* 228 */ 9999,
/* 229 */ 9999,
/* 230 */ 9999,
/* 231 */ 9999,
/* 232 */ 19005,
/* 233 */ 9999,
/* 234 */ 19024,
/* 235 */ 9999,
/* 236 */ 19024,
/* 237 */ 9999,
/* 238 */ 19029,
/* 239 */ 9999,
/* 240 */ 19029,
/* 241 */ 9999,
/* 242 */ 9999,
/* 243 */ 19038,
/* 244 */ 19040,
/* 245 */ 9999,
/* 246 */ 9999,
/* 247 */ 9999,
/* 248 */ 19034,
/* 249 */ 9999,
/* 250 */ 9999,
/* 251 */ 9999,
/* 252 */ 19053,
/* 253 */ 9999,
/* 254 */ 9999,
/* 255 */ 9999,
/* 256 */ 19060,
/* 257 */ 9999,
/* 258 */ 9999,
/* 259 */ 19071,
/* 260 */ 9999,
/* 261 */ 19077,
/* 262 */ 19079,
/* 263 */ 9999,
/* 264 */ 19085,
/* 265 */ 9999,
/* 266 */ 19067,
0
};
/* only for BIGHASH (see art.c)
extern int DHITS[];
int DHITS[268];
*/
int TABLE[40][256];
init_dirsets() {
TABLE[39][101] = 1;
TABLE[39][102] = 1;
TABLE[39][104] = 1;
TABLE[39][103] = 1;
TABLE[39][98] = 1;
TABLE[39][99] = 1;
TABLE[39][97] = 1;
TABLE[39][100] = 1;
TABLE[1][102] = 1;
TABLE[1][99] = 1;
TABLE[1][98] = 1;
TABLE[1][101] = 1;
TABLE[1][103] = 1;
TABLE[1][104] = 1;
TABLE[1][100] = 1;
TABLE[1][97] = 1;
TABLE[2][101] = 1;
TABLE[3][102] = 1;
TABLE[4][103] = 1;
TABLE[4][104] = 1;
TABLE[4][99] = 1;
TABLE[4][102] = 1;
TABLE[4][100] = 1;
TABLE[4][98] = 1;
TABLE[4][101] = 1;
TABLE[4][97] = 1;
TABLE[5][104] = 1;
TABLE[6][102] = 1;
TABLE[7][99] = 1;
TABLE[7][98] = 1;
TABLE[7][101] = 1;
TABLE[7][104] = 1;
TABLE[7][103] = 1;
TABLE[7][97] = 1;
TABLE[7][100] = 1;
TABLE[7][102] = 1;
TABLE[8][103] = 1;
TABLE[8][101] = 1;
TABLE[8][98] = 1;
TABLE[8][99] = 1;
TABLE[8][104] = 1;
TABLE[8][97] = 1;
TABLE[8][100] = 1;
TABLE[8][102] = 1;
TABLE[9][101] = 1;
TABLE[10][98] = 1;
TABLE[11][103] = 1;
TABLE[11][104] = 1;
TABLE[11][99] = 1;
TABLE[11][102] = 1;
TABLE[11][100] = 1;
TABLE[11][98] = 1;
TABLE[11][101] = 1;
TABLE[11][97] = 1;
TABLE[12][103] = 1;
TABLE[12][104] = 1;
TABLE[12][99] = 1;
TABLE[12][102] = 1;
TABLE[12][100] = 1;
TABLE[12][98] = 1;
TABLE[12][101] = 1;
TABLE[12][97] = 1;
TABLE[13][99] = 1;
TABLE[14][101] = 1;
TABLE[14][98] = 1;
TABLE[14][99] = 1;
TABLE[14][103] = 1;
TABLE[14][104] = 1;
TABLE[14][97] = 1;
TABLE[14][100] = 1;
TABLE[14][102] = 1;
TABLE[15][104] = 1;
TABLE[15][101] = 1;
TABLE[16][103] = 1;
TABLE[16][104] = 1;
TABLE[16][99] = 1;
TABLE[16][102] = 1;
TABLE[16][100] = 1;
TABLE[16][98] = 1;
TABLE[16][101] = 1;
TABLE[16][97] = 1;
TABLE[17][103] = 1;
TABLE[18][99] = 1;
TABLE[18][98] = 1;
TABLE[18][101] = 1;
TABLE[18][104] = 1;
TABLE[18][103] = 1;
TABLE[18][97] = 1;
TABLE[18][100] = 1;
TABLE[18][102] = 1;
TABLE[19][103] = 1;
TABLE[20][103] = 1;
TABLE[21][97] = 1;
TABLE[21][101] = 1;
TABLE[21][104] = 1;
TABLE[21][103] = 1;
TABLE[21][98] = 1;
TABLE[21][100] = 1;
TABLE[21][102] = 1;
TABLE[21][99] = 1;
TABLE[22][104] = 1;
TABLE[23][102] = 1;
TABLE[24][103] = 1;
TABLE[24][101] = 1;
TABLE[24][98] = 1;
TABLE[24][99] = 1;
TABLE[24][104] = 1;
TABLE[24][97] = 1;
TABLE[24][100] = 1;
TABLE[24][102] = 1;
TABLE[25][102] = 1;
TABLE[26][100] = 1;
TABLE[27][98] = 1;
TABLE[28][103] = 1;
TABLE[29][104] = 1;
TABLE[30][101] = 1;
TABLE[31][101] = 1;
TABLE[32][97] = 1;
TABLE[33][104] = 1;
TABLE[33][101] = 1;
TABLE[34][102] = 1;
TABLE[34][100] = 1;
TABLE[34][98] = 1;
TABLE[34][103] = 1;
TABLE[35][99] = 1;
TABLE[36][98] = 1;
TABLE[37][99] = 1;
TABLE[38][104] = 1;
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
      case 48: return 0; break;
      case 73: return 0; break;
      case 96: return 0; break;
      case 125: return 0; break;
      case 156: return 0; break;
      case 172: return 0; break;
      case 198: return 0; break;
      case 226: return 0; break;
   }
}
char * yyprintname(n)
   int n;
{
   if (n <= 50000)
      switch(n) {
         case 1: return "YYSTART"; break;
         case 6: return "root"; break;
         case 48: return "A"; break;
         case 73: return "B"; break;
         case 96: return "C"; break;
         case 125: return "D"; break;
         case 156: return "E"; break;
         case 172: return "F"; break;
         case 198: return "G"; break;
         case 226: return "H"; break;
   }
   else 
      switch(n-50000) {
      }
   return "special_character";
}