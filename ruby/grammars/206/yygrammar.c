#include "yygrammar.h"

YYSTART ()
{
   switch(yyselect()) {
   case 37: {
      root();
      get_lexval();
      } break;
   }
}

root ()
{
   switch(yyselect()) {
   case 1: {
      get_lexval();
      get_lexval();
      A();
      E();
      H();
      get_lexval();
      } break;
   case 2: {
      get_lexval();
      get_lexval();
      get_lexval();
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
      get_lexval();
      } break;
   }
}

A ()
{
   switch(yyselect()) {
   case 5: {
      get_lexval();
      G();
      E();
      } break;
   case 6: {
      D();
      E();
      get_lexval();
      } break;
   case 7: {
      get_lexval();
      E();
      } break;
   case 8: {
      F();
      get_lexval();
      get_lexval();
      get_lexval();
      H();
      get_lexval();
      } break;
   case 9: {
      C();
      F();
      get_lexval();
      get_lexval();
      } break;
   }
}

B ()
{
   switch(yyselect()) {
   case 10: {
      get_lexval();
      } break;
   case 11: {
      get_lexval();
      get_lexval();
      A();
      get_lexval();
      get_lexval();
      C();
      } break;
   }
}

C ()
{
   switch(yyselect()) {
   case 12: {
      get_lexval();
      C();
      get_lexval();
      } break;
   case 13: {
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      get_lexval();
      } break;
   case 14: {
      B();
      get_lexval();
      get_lexval();
      } break;
   case 15: {
      F();
      get_lexval();
      E();
      } break;
   case 16: {
      H();
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
      C();
      G();
      } break;
   }
}

D ()
{
   switch(yyselect()) {
   case 19: {
      get_lexval();
      F();
      H();
      } break;
   case 20: {
      D();
      B();
      F();
      } break;
   case 21: {
      get_lexval();
      B();
      get_lexval();
      F();
      get_lexval();
      H();
      E();
      } break;
   }
}

E ()
{
   switch(yyselect()) {
   case 22: {
      get_lexval();
      get_lexval();
      } break;
   case 23: {
      get_lexval();
      D();
      G();
      B();
      H();
      } break;
   case 24: {
      A();
      get_lexval();
      get_lexval();
      F();
      get_lexval();
      G();
      get_lexval();
      } break;
   case 25: {
      F();
      F();
      C();
      H();
      get_lexval();
      D();
      } break;
   case 26: {
      A();
      get_lexval();
      B();
      get_lexval();
      get_lexval();
      F();
      get_lexval();
      } break;
   }
}

F ()
{
   switch(yyselect()) {
   case 27: {
      A();
      } break;
   case 28: {
      get_lexval();
      } break;
   }
}

G ()
{
   switch(yyselect()) {
   case 29: {
      B();
      } break;
   case 30: {
      get_lexval();
      get_lexval();
      get_lexval();
      B();
      get_lexval();
      get_lexval();
      } break;
   case 31: {
      get_lexval();
      get_lexval();
      get_lexval();
      H();
      E();
      D();
      B();
      } break;
   case 32: {
      get_lexval();
      B();
      H();
      C();
      } break;
   }
}

H ()
{
   switch(yyselect()) {
   case 33: {
      get_lexval();
      } break;
   case 34: {
      A();
      G();
      get_lexval();
      } break;
   case 35: {
      get_lexval();
      get_lexval();
      A();
      H();
      get_lexval();
      } break;
   case 36: {
      C();
      C();
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
int c_length = 250;
extern int yygrammar[];
int yygrammar[] = {
0,
/* 1 */ 0,
/* 2 */ 6,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 37,
/* 6 */ 15,
/* 7 */ 50104,
/* 8 */ 50100,
/* 9 */ 34,
/* 10 */ 148,
/* 11 */ 228,
/* 12 */ 50102,
/* 13 */ -6,
/* 14 */ 1,
/* 15 */ 24,
/* 16 */ 50103,
/* 17 */ 50097,
/* 18 */ 50104,
/* 19 */ 50097,
/* 20 */ 50098,
/* 21 */ 50104,
/* 22 */ -6,
/* 23 */ 2,
/* 24 */ 30,
/* 25 */ 50102,
/* 26 */ 50100,
/* 27 */ 50102,
/* 28 */ -6,
/* 29 */ 3,
/* 30 */ 0,
/* 31 */ 50100,
/* 32 */ -6,
/* 33 */ 4,
/* 34 */ 40,
/* 35 */ 50102,
/* 36 */ 198,
/* 37 */ 148,
/* 38 */ -34,
/* 39 */ 5,
/* 40 */ 46,
/* 41 */ 126,
/* 42 */ 148,
/* 43 */ 50097,
/* 44 */ -34,
/* 45 */ 6,
/* 46 */ 51,
/* 47 */ 50097,
/* 48 */ 148,
/* 49 */ -34,
/* 50 */ 7,
/* 51 */ 60,
/* 52 */ 190,
/* 53 */ 50102,
/* 54 */ 50099,
/* 55 */ 50103,
/* 56 */ 228,
/* 57 */ 50104,
/* 58 */ -34,
/* 59 */ 8,
/* 60 */ 0,
/* 61 */ 80,
/* 62 */ 190,
/* 63 */ 50100,
/* 64 */ 50097,
/* 65 */ -34,
/* 66 */ 9,
/* 67 */ 71,
/* 68 */ 50101,
/* 69 */ -67,
/* 70 */ 10,
/* 71 */ 0,
/* 72 */ 50098,
/* 73 */ 50098,
/* 74 */ 34,
/* 75 */ 50103,
/* 76 */ 50100,
/* 77 */ 80,
/* 78 */ -67,
/* 79 */ 11,
/* 80 */ 86,
/* 81 */ 50100,
/* 82 */ 80,
/* 83 */ 50098,
/* 84 */ -80,
/* 85 */ 12,
/* 86 */ 95,
/* 87 */ 50102,
/* 88 */ 50102,
/* 89 */ 50101,
/* 90 */ 50097,
/* 91 */ 50104,
/* 92 */ 50102,
/* 93 */ -80,
/* 94 */ 13,
/* 95 */ 101,
/* 96 */ 67,
/* 97 */ 50103,
/* 98 */ 50100,
/* 99 */ -80,
/* 100 */ 14,
/* 101 */ 107,
/* 102 */ 190,
/* 103 */ 50099,
/* 104 */ 148,
/* 105 */ -80,
/* 106 */ 15,
/* 107 */ 111,
/* 108 */ 228,
/* 109 */ -80,
/* 110 */ 16,
/* 111 */ 121,
/* 112 */ 50097,
/* 113 */ 50099,
/* 114 */ 50097,
/* 115 */ 50098,
/* 116 */ 50100,
/* 117 */ 50100,
/* 118 */ 50097,
/* 119 */ -80,
/* 120 */ 17,
/* 121 */ 0,
/* 122 */ 80,
/* 123 */ 198,
/* 124 */ -80,
/* 125 */ 18,
/* 126 */ 132,
/* 127 */ 50100,
/* 128 */ 190,
/* 129 */ 228,
/* 130 */ -126,
/* 131 */ 19,
/* 132 */ 138,
/* 133 */ 126,
/* 134 */ 67,
/* 135 */ 190,
/* 136 */ -126,
/* 137 */ 20,
/* 138 */ 0,
/* 139 */ 50099,
/* 140 */ 67,
/* 141 */ 50097,
/* 142 */ 190,
/* 143 */ 50100,
/* 144 */ 228,
/* 145 */ 148,
/* 146 */ -126,
/* 147 */ 21,
/* 148 */ 153,
/* 149 */ 50101,
/* 150 */ 50100,
/* 151 */ -148,
/* 152 */ 22,
/* 153 */ 161,
/* 154 */ 50104,
/* 155 */ 126,
/* 156 */ 198,
/* 157 */ 67,
/* 158 */ 228,
/* 159 */ -148,
/* 160 */ 23,
/* 161 */ 171,
/* 162 */ 34,
/* 163 */ 50099,
/* 164 */ 50102,
/* 165 */ 190,
/* 166 */ 50103,
/* 167 */ 198,
/* 168 */ 50104,
/* 169 */ -148,
/* 170 */ 24,
/* 171 */ 180,
/* 172 */ 190,
/* 173 */ 190,
/* 174 */ 80,
/* 175 */ 228,
/* 176 */ 50099,
/* 177 */ 126,
/* 178 */ -148,
/* 179 */ 25,
/* 180 */ 0,
/* 181 */ 34,
/* 182 */ 50100,
/* 183 */ 67,
/* 184 */ 50100,
/* 185 */ 50099,
/* 186 */ 190,
/* 187 */ 50103,
/* 188 */ -148,
/* 189 */ 26,
/* 190 */ 194,
/* 191 */ 34,
/* 192 */ -190,
/* 193 */ 27,
/* 194 */ 0,
/* 195 */ 50101,
/* 196 */ -190,
/* 197 */ 28,
/* 198 */ 202,
/* 199 */ 67,
/* 200 */ -198,
/* 201 */ 29,
/* 202 */ 211,
/* 203 */ 50101,
/* 204 */ 50104,
/* 205 */ 50100,
/* 206 */ 67,
/* 207 */ 50097,
/* 208 */ 50103,
/* 209 */ -198,
/* 210 */ 30,
/* 211 */ 221,
/* 212 */ 50098,
/* 213 */ 50099,
/* 214 */ 50104,
/* 215 */ 228,
/* 216 */ 148,
/* 217 */ 126,
/* 218 */ 67,
/* 219 */ -198,
/* 220 */ 31,
/* 221 */ 0,
/* 222 */ 50100,
/* 223 */ 67,
/* 224 */ 228,
/* 225 */ 80,
/* 226 */ -198,
/* 227 */ 32,
/* 228 */ 232,
/* 229 */ 50098,
/* 230 */ -228,
/* 231 */ 33,
/* 232 */ 238,
/* 233 */ 34,
/* 234 */ 198,
/* 235 */ 50103,
/* 236 */ -228,
/* 237 */ 34,
/* 238 */ 246,
/* 239 */ 50101,
/* 240 */ 50102,
/* 241 */ 34,
/* 242 */ 228,
/* 243 */ 50104,
/* 244 */ -228,
/* 245 */ 35,
/* 246 */ 0,
/* 247 */ 80,
/* 248 */ 80,
/* 249 */ -228,
/* 250 */ 36,
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
/* 6 */ 15,
/* 7 */ 50104,
/* 8 */ 50100,
/* 9 */ 0,
/* 10 */ 0,
/* 11 */ 0,
/* 12 */ 50102,
/* 13 */ -6,
/* 14 */ -1,
/* 15 */ 24,
/* 16 */ 50103,
/* 17 */ 50097,
/* 18 */ 50104,
/* 19 */ 50097,
/* 20 */ 50098,
/* 21 */ 50104,
/* 22 */ -6,
/* 23 */ -1,
/* 24 */ 30,
/* 25 */ 50102,
/* 26 */ 50100,
/* 27 */ 50102,
/* 28 */ -6,
/* 29 */ -1,
/* 30 */ 0,
/* 31 */ 50100,
/* 32 */ -6,
/* 33 */ -1,
/* 34 */ 40,
/* 35 */ 50102,
/* 36 */ 0,
/* 37 */ 0,
/* 38 */ -34,
/* 39 */ -1,
/* 40 */ 46,
/* 41 */ 0,
/* 42 */ 0,
/* 43 */ 50097,
/* 44 */ -34,
/* 45 */ -1,
/* 46 */ 51,
/* 47 */ 50097,
/* 48 */ 0,
/* 49 */ -34,
/* 50 */ -1,
/* 51 */ 60,
/* 52 */ 0,
/* 53 */ 50102,
/* 54 */ 50099,
/* 55 */ 50103,
/* 56 */ 0,
/* 57 */ 50104,
/* 58 */ -34,
/* 59 */ -1,
/* 60 */ 0,
/* 61 */ 0,
/* 62 */ 0,
/* 63 */ 50100,
/* 64 */ 50097,
/* 65 */ -34,
/* 66 */ -1,
/* 67 */ 71,
/* 68 */ 50101,
/* 69 */ -67,
/* 70 */ -1,
/* 71 */ 0,
/* 72 */ 50098,
/* 73 */ 50098,
/* 74 */ 0,
/* 75 */ 50103,
/* 76 */ 50100,
/* 77 */ 0,
/* 78 */ -67,
/* 79 */ -1,
/* 80 */ 86,
/* 81 */ 50100,
/* 82 */ 0,
/* 83 */ 50098,
/* 84 */ -80,
/* 85 */ -1,
/* 86 */ 95,
/* 87 */ 50102,
/* 88 */ 50102,
/* 89 */ 50101,
/* 90 */ 50097,
/* 91 */ 50104,
/* 92 */ 50102,
/* 93 */ -80,
/* 94 */ -1,
/* 95 */ 101,
/* 96 */ 0,
/* 97 */ 50103,
/* 98 */ 50100,
/* 99 */ -80,
/* 100 */ -1,
/* 101 */ 107,
/* 102 */ 0,
/* 103 */ 50099,
/* 104 */ 0,
/* 105 */ -80,
/* 106 */ -1,
/* 107 */ 111,
/* 108 */ 0,
/* 109 */ -80,
/* 110 */ -1,
/* 111 */ 121,
/* 112 */ 50097,
/* 113 */ 50099,
/* 114 */ 50097,
/* 115 */ 50098,
/* 116 */ 50100,
/* 117 */ 50100,
/* 118 */ 50097,
/* 119 */ -80,
/* 120 */ -1,
/* 121 */ 0,
/* 122 */ 0,
/* 123 */ 0,
/* 124 */ -80,
/* 125 */ -1,
/* 126 */ 132,
/* 127 */ 50100,
/* 128 */ 0,
/* 129 */ 0,
/* 130 */ -126,
/* 131 */ -1,
/* 132 */ 138,
/* 133 */ 0,
/* 134 */ 0,
/* 135 */ 0,
/* 136 */ -126,
/* 137 */ -1,
/* 138 */ 0,
/* 139 */ 50099,
/* 140 */ 0,
/* 141 */ 50097,
/* 142 */ 0,
/* 143 */ 50100,
/* 144 */ 0,
/* 145 */ 0,
/* 146 */ -126,
/* 147 */ -1,
/* 148 */ 153,
/* 149 */ 50101,
/* 150 */ 50100,
/* 151 */ -148,
/* 152 */ -1,
/* 153 */ 161,
/* 154 */ 50104,
/* 155 */ 0,
/* 156 */ 0,
/* 157 */ 0,
/* 158 */ 0,
/* 159 */ -148,
/* 160 */ -1,
/* 161 */ 171,
/* 162 */ 0,
/* 163 */ 50099,
/* 164 */ 50102,
/* 165 */ 0,
/* 166 */ 50103,
/* 167 */ 0,
/* 168 */ 50104,
/* 169 */ -148,
/* 170 */ -1,
/* 171 */ 180,
/* 172 */ 0,
/* 173 */ 0,
/* 174 */ 0,
/* 175 */ 0,
/* 176 */ 50099,
/* 177 */ 0,
/* 178 */ -148,
/* 179 */ -1,
/* 180 */ 0,
/* 181 */ 0,
/* 182 */ 50100,
/* 183 */ 0,
/* 184 */ 50100,
/* 185 */ 50099,
/* 186 */ 0,
/* 187 */ 50103,
/* 188 */ -148,
/* 189 */ -1,
/* 190 */ 194,
/* 191 */ 0,
/* 192 */ -190,
/* 193 */ -1,
/* 194 */ 0,
/* 195 */ 50101,
/* 196 */ -190,
/* 197 */ -1,
/* 198 */ 202,
/* 199 */ 0,
/* 200 */ -198,
/* 201 */ -1,
/* 202 */ 211,
/* 203 */ 50101,
/* 204 */ 50104,
/* 205 */ 50100,
/* 206 */ 0,
/* 207 */ 50097,
/* 208 */ 50103,
/* 209 */ -198,
/* 210 */ -1,
/* 211 */ 221,
/* 212 */ 50098,
/* 213 */ 50099,
/* 214 */ 50104,
/* 215 */ 0,
/* 216 */ 0,
/* 217 */ 0,
/* 218 */ 0,
/* 219 */ -198,
/* 220 */ -1,
/* 221 */ 0,
/* 222 */ 50100,
/* 223 */ 0,
/* 224 */ 0,
/* 225 */ 0,
/* 226 */ -198,
/* 227 */ -1,
/* 228 */ 232,
/* 229 */ 50098,
/* 230 */ -228,
/* 231 */ -1,
/* 232 */ 238,
/* 233 */ 0,
/* 234 */ 0,
/* 235 */ 50103,
/* 236 */ -228,
/* 237 */ -1,
/* 238 */ 246,
/* 239 */ 50101,
/* 240 */ 50102,
/* 241 */ 0,
/* 242 */ 0,
/* 243 */ 50104,
/* 244 */ -228,
/* 245 */ -1,
/* 246 */ 0,
/* 247 */ 0,
/* 248 */ 0,
/* 249 */ -228,
/* 250 */ -1,
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
/* 7 */ 9999,
/* 8 */ 9999,
/* 9 */ 3016,
/* 10 */ 3018,
/* 11 */ 3020,
/* 12 */ 9999,
/* 13 */ 9999,
/* 14 */ 3008,
/* 15 */ 9999,
/* 16 */ 9999,
/* 17 */ 9999,
/* 18 */ 9999,
/* 19 */ 9999,
/* 20 */ 9999,
/* 21 */ 9999,
/* 22 */ 9999,
/* 23 */ 3029,
/* 24 */ 9999,
/* 25 */ 9999,
/* 26 */ 9999,
/* 27 */ 9999,
/* 28 */ 9999,
/* 29 */ 3056,
/* 30 */ 9999,
/* 31 */ 9999,
/* 32 */ 9999,
/* 33 */ 3071,
/* 34 */ 9999,
/* 35 */ 9999,
/* 36 */ 5009,
/* 37 */ 5011,
/* 38 */ 9999,
/* 39 */ 5005,
/* 40 */ 9999,
/* 41 */ 5016,
/* 42 */ 5018,
/* 43 */ 9999,
/* 44 */ 9999,
/* 45 */ 5016,
/* 46 */ 9999,
/* 47 */ 9999,
/* 48 */ 5031,
/* 49 */ 9999,
/* 50 */ 5027,
/* 51 */ 9999,
/* 52 */ 5036,
/* 53 */ 9999,
/* 54 */ 9999,
/* 55 */ 9999,
/* 56 */ 5050,
/* 57 */ 9999,
/* 58 */ 9999,
/* 59 */ 5036,
/* 60 */ 9999,
/* 61 */ 5059,
/* 62 */ 5061,
/* 63 */ 9999,
/* 64 */ 9999,
/* 65 */ 9999,
/* 66 */ 5059,
/* 67 */ 9999,
/* 68 */ 9999,
/* 69 */ 9999,
/* 70 */ 7005,
/* 71 */ 9999,
/* 72 */ 9999,
/* 73 */ 9999,
/* 74 */ 7020,
/* 75 */ 9999,
/* 76 */ 9999,
/* 77 */ 7030,
/* 78 */ 9999,
/* 79 */ 7012,
/* 80 */ 9999,
/* 81 */ 9999,
/* 82 */ 9009,
/* 83 */ 9999,
/* 84 */ 9999,
/* 85 */ 9005,
/* 86 */ 9999,
/* 87 */ 9999,
/* 88 */ 9999,
/* 89 */ 9999,
/* 90 */ 9999,
/* 91 */ 9999,
/* 92 */ 9999,
/* 93 */ 9999,
/* 94 */ 9018,
/* 95 */ 9999,
/* 96 */ 9045,
/* 97 */ 9999,
/* 98 */ 9999,
/* 99 */ 9999,
/* 100 */ 9045,
/* 101 */ 9999,
/* 102 */ 9058,
/* 103 */ 9999,
/* 104 */ 9064,
/* 105 */ 9999,
/* 106 */ 9058,
/* 107 */ 9999,
/* 108 */ 9069,
/* 109 */ 9999,
/* 110 */ 9069,
/* 111 */ 9999,
/* 112 */ 9999,
/* 113 */ 9999,
/* 114 */ 9999,
/* 115 */ 9999,
/* 116 */ 9999,
/* 117 */ 9999,
/* 118 */ 9999,
/* 119 */ 9999,
/* 120 */ 9074,
/* 121 */ 9999,
/* 122 */ 9105,
/* 123 */ 9107,
/* 124 */ 9999,
/* 125 */ 9105,
/* 126 */ 9999,
/* 127 */ 9999,
/* 128 */ 11009,
/* 129 */ 11011,
/* 130 */ 9999,
/* 131 */ 11005,
/* 132 */ 9999,
/* 133 */ 11016,
/* 134 */ 11018,
/* 135 */ 11020,
/* 136 */ 9999,
/* 137 */ 11016,
/* 138 */ 9999,
/* 139 */ 9999,
/* 140 */ 11029,
/* 141 */ 9999,
/* 142 */ 11035,
/* 143 */ 9999,
/* 144 */ 11041,
/* 145 */ 11043,
/* 146 */ 9999,
/* 147 */ 11025,
/* 148 */ 9999,
/* 149 */ 9999,
/* 150 */ 9999,
/* 151 */ 9999,
/* 152 */ 13005,
/* 153 */ 9999,
/* 154 */ 9999,
/* 155 */ 13020,
/* 156 */ 13022,
/* 157 */ 13024,
/* 158 */ 13026,
/* 159 */ 9999,
/* 160 */ 13016,
/* 161 */ 9999,
/* 162 */ 13031,
/* 163 */ 9999,
/* 164 */ 9999,
/* 165 */ 13041,
/* 166 */ 9999,
/* 167 */ 13047,
/* 168 */ 9999,
/* 169 */ 9999,
/* 170 */ 13031,
/* 171 */ 9999,
/* 172 */ 13056,
/* 173 */ 13058,
/* 174 */ 13060,
/* 175 */ 13062,
/* 176 */ 9999,
/* 177 */ 13068,
/* 178 */ 9999,
/* 179 */ 13056,
/* 180 */ 9999,
/* 181 */ 13073,
/* 182 */ 9999,
/* 183 */ 13079,
/* 184 */ 9999,
/* 185 */ 9999,
/* 186 */ 13089,
/* 187 */ 9999,
/* 188 */ 9999,
/* 189 */ 13073,
/* 190 */ 9999,
/* 191 */ 15005,
/* 192 */ 9999,
/* 193 */ 15005,
/* 194 */ 9999,
/* 195 */ 9999,
/* 196 */ 9999,
/* 197 */ 15010,
/* 198 */ 9999,
/* 199 */ 17005,
/* 200 */ 9999,
/* 201 */ 17005,
/* 202 */ 9999,
/* 203 */ 9999,
/* 204 */ 9999,
/* 205 */ 9999,
/* 206 */ 17022,
/* 207 */ 9999,
/* 208 */ 9999,
/* 209 */ 9999,
/* 210 */ 17010,
/* 211 */ 9999,
/* 212 */ 9999,
/* 213 */ 9999,
/* 214 */ 9999,
/* 215 */ 17047,
/* 216 */ 17049,
/* 217 */ 17051,
/* 218 */ 17053,
/* 219 */ 9999,
/* 220 */ 17035,
/* 221 */ 9999,
/* 222 */ 9999,
/* 223 */ 17062,
/* 224 */ 17064,
/* 225 */ 17066,
/* 226 */ 9999,
/* 227 */ 17058,
/* 228 */ 9999,
/* 229 */ 9999,
/* 230 */ 9999,
/* 231 */ 19005,
/* 232 */ 9999,
/* 233 */ 19012,
/* 234 */ 19014,
/* 235 */ 9999,
/* 236 */ 9999,
/* 237 */ 19012,
/* 238 */ 9999,
/* 239 */ 9999,
/* 240 */ 9999,
/* 241 */ 19031,
/* 242 */ 19033,
/* 243 */ 9999,
/* 244 */ 9999,
/* 245 */ 19023,
/* 246 */ 9999,
/* 247 */ 19042,
/* 248 */ 19044,
/* 249 */ 9999,
/* 250 */ 19042,
0
};
/* only for BIGHASH (see art.c)
extern int DHITS[];
int DHITS[252];
*/
int TABLE[38][256];
init_dirsets() {
TABLE[37][104] = 1;
TABLE[37][103] = 1;
TABLE[37][102] = 1;
TABLE[37][100] = 1;
TABLE[1][104] = 1;
TABLE[2][103] = 1;
TABLE[3][102] = 1;
TABLE[4][100] = 1;
TABLE[5][102] = 1;
TABLE[6][100] = 1;
TABLE[6][99] = 1;
TABLE[7][97] = 1;
TABLE[8][97] = 1;
TABLE[8][102] = 1;
TABLE[8][101] = 1;
TABLE[8][98] = 1;
TABLE[8][100] = 1;
TABLE[8][99] = 1;
TABLE[9][100] = 1;
TABLE[9][102] = 1;
TABLE[9][98] = 1;
TABLE[9][101] = 1;
TABLE[9][97] = 1;
TABLE[9][99] = 1;
TABLE[10][101] = 1;
TABLE[11][98] = 1;
TABLE[12][100] = 1;
TABLE[13][102] = 1;
TABLE[14][101] = 1;
TABLE[14][98] = 1;
TABLE[15][97] = 1;
TABLE[15][102] = 1;
TABLE[15][101] = 1;
TABLE[15][98] = 1;
TABLE[15][100] = 1;
TABLE[15][99] = 1;
TABLE[16][98] = 1;
TABLE[16][97] = 1;
TABLE[16][102] = 1;
TABLE[16][101] = 1;
TABLE[16][100] = 1;
TABLE[16][99] = 1;
TABLE[17][97] = 1;
TABLE[18][100] = 1;
TABLE[18][102] = 1;
TABLE[18][98] = 1;
TABLE[18][101] = 1;
TABLE[18][97] = 1;
TABLE[18][99] = 1;
TABLE[19][100] = 1;
TABLE[20][100] = 1;
TABLE[20][99] = 1;
TABLE[21][99] = 1;
TABLE[22][101] = 1;
TABLE[23][104] = 1;
TABLE[24][102] = 1;
TABLE[24][97] = 1;
TABLE[24][99] = 1;
TABLE[24][100] = 1;
TABLE[24][101] = 1;
TABLE[24][98] = 1;
TABLE[25][97] = 1;
TABLE[25][102] = 1;
TABLE[25][101] = 1;
TABLE[25][98] = 1;
TABLE[25][100] = 1;
TABLE[25][99] = 1;
TABLE[26][102] = 1;
TABLE[26][97] = 1;
TABLE[26][99] = 1;
TABLE[26][100] = 1;
TABLE[26][101] = 1;
TABLE[26][98] = 1;
TABLE[27][102] = 1;
TABLE[27][97] = 1;
TABLE[27][99] = 1;
TABLE[27][100] = 1;
TABLE[27][101] = 1;
TABLE[27][98] = 1;
TABLE[28][101] = 1;
TABLE[29][101] = 1;
TABLE[29][98] = 1;
TABLE[30][101] = 1;
TABLE[31][98] = 1;
TABLE[32][100] = 1;
TABLE[33][98] = 1;
TABLE[34][102] = 1;
TABLE[34][97] = 1;
TABLE[34][99] = 1;
TABLE[34][100] = 1;
TABLE[34][101] = 1;
TABLE[34][98] = 1;
TABLE[35][101] = 1;
TABLE[36][100] = 1;
TABLE[36][102] = 1;
TABLE[36][98] = 1;
TABLE[36][101] = 1;
TABLE[36][97] = 1;
TABLE[36][99] = 1;
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
      case 34: return 0; break;
      case 67: return 0; break;
      case 80: return 0; break;
      case 126: return 0; break;
      case 148: return 0; break;
      case 190: return 0; break;
      case 198: return 0; break;
      case 228: return 0; break;
   }
}
char * yyprintname(n)
   int n;
{
   if (n <= 50000)
      switch(n) {
         case 1: return "YYSTART"; break;
         case 6: return "root"; break;
         case 34: return "A"; break;
         case 67: return "B"; break;
         case 80: return "C"; break;
         case 126: return "D"; break;
         case 148: return "E"; break;
         case 190: return "F"; break;
         case 198: return "G"; break;
         case 228: return "H"; break;
   }
   else 
      switch(n-50000) {
      }
   return "special_character";
}