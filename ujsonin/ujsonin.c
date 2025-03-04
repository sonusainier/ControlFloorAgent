// Copyright (C) 2020 David Helkowski
// Anti-Corruption License ( AC_LICENSE.TXT )

#include<stdio.h>
#include<stdint.h>
#include"red_black_tree.h"
#include"string-tree.h"

#include"ujsonin.h"

node_hash *parse_with_default( char *file, char *def, char **d1, char **d2 ) {
    long flen;
    char *fdata = slurp_file( (char *) file, &flen );
    if( !fdata ) {
        printf("Could not open file '%s'\n", file );
        exit(1);
    }
    int ferr;
    node_hash *froot = parse( fdata, flen, NULL, &ferr );
    long dlen;
    char *ddata = NULL;
    int derr;
    
    node_hash *both;
    if( def ) {
        ddata = slurp_file( (char *) def, &dlen );
        both = parse( ddata, dlen, NULL, &derr );
    }
    else {
        both = froot;
    }
    *d1 = fdata;
    if( ddata ) *d2 = ddata;
    return both;
}

char *slurp_file( char *filename, long *outlen ) {
    FILE *fh = fopen( filename, "r" );
    fseek( fh, 0, SEEK_END );
    long int fileLength = ftell( fh );
    fseek( fh, 0, SEEK_SET );
    char *input = malloc( fileLength + 1 );
    input[ fileLength ] = 0x00;
    fread( input, (size_t) fileLength, (size_t) 1, fh );
    *outlen = fileLength;
    return input;
}

jnode *jnode__new( char type ) {
    jnode *self = ( jnode * ) calloc( sizeof( jnode ), 1 );
    self->type = type;
    return self;
}

node_hash *node_hash__new(void) {
    node_hash *self = ( node_hash * ) calloc( sizeof( node_hash ), 1 );
    self->type = 1;
    self->tree = string_tree__new();
    return self;
}

node_str *node_str__new( char *str, long len, char type ) {
    node_str *self = ( node_str * ) calloc( sizeof( node_str ), 1 );
    self->type = type; // 2 is str, 4 is number, 5 is a negative number
    self->str = str;
    self->len = len;
    return self;
}

node_arr *node_arr__new(void) {
    node_arr *self = ( node_arr * ) calloc( sizeof( node_arr ), 1 );
    self->type = 3;
    return self;
}

void node_arr__add( node_arr *self, jnode *el ) {
    self->count++;
    if( !self->head ) {
        self->head = self->tail = el;
        return;
    }
    self->tail->parent = el;
    self->tail = el;
}

void node_hash__dump( node_hash *self, int depth ) {
    xjr_key_arr *keys = string_tree__getkeys( self->tree );
    printf("{\n");
    for( int i=0;i<keys->count;i++ ) {
        char *key = keys->items[i];
        int len = keys->sizes[i];
        SPACES printf("\"%.*s\":",len,key);
        jnode__dump( node_hash__get( self, key, len ), depth );
    }
    depth--;
    SPACES printf("}\n");
}

void node_hash__delete( node_hash *self ) {
    xjr_key_arr *keys = string_tree__getkeys( self->tree );
    for( int i=0;i<keys->count;i++ ) {
        char *key = keys->items[i];
        int len = keys->sizes[i];
        jnode *sub = node_hash__get( self, key, len );
        if( sub->type == 1 ) node_hash__delete( (node_hash *) sub );
        else free( sub );
    }
    xjr_key_arr__delete( keys );
    string_tree__delete( self->tree );
    free( self );
}

void jnode__dump_to_makefile( jnode *self, char *prefix );
void node_hash__dump_to_makefile( node_hash *self, char *prefix ) {
    xjr_key_arr *keys = string_tree__getkeys( self->tree );
    char pref2[ 100 ];
    for( int i=0;i<keys->count;i++ ) {
        char *key = keys->items[i];
        int len = keys->sizes[i];
        jnode *val = node_hash__get( self, key, len );
        if( val->type != 1 ) printf("%s%.*s := ",prefix?prefix:"",len,key);
        else {
            if( prefix ) sprintf( pref2, "%s%.*s_", prefix, len, key );
            else sprintf( pref2, "%.*s", len, key );
            prefix = pref2;
        }
        jnode__dump_to_makefile( val, prefix );
    }
}

void node_arr__dump( node_arr *self, int depth ) {
    printf("[\n");
    jnode *cur = self->head;
    for( int i=0;i<self->count;i++ ) {
        SPACES jnode__dump( cur, depth+1 );
        cur = cur->parent; // parent is being reused as next
    }
    depth--;
    SPACES printf("]\n");
}

void jnode__dump( jnode *self, int depth ) {
    if( self->type == 1 ) node_hash__dump( (node_hash *) self, depth+1 );
    else if( self->type == 2 ) printf("\"%.*s\"\n", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    else if( self->type == 3 ) node_arr__dump( (node_arr *) self, depth+1 );
    else if( self->type == 4 ) printf("%.*s\n", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    else if( self->type == 5 ) printf("-%.*s\n", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    else if( self->type == 6 ) printf("true\n");
    else if( self->type == 7 ) printf("false\n");
    else if( self->type == 8 ) printf("false\n");
    else if( self->type == 9 ) printf("%.*s\n", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
}

void jnode__dump_to_makefile( jnode *self, char *prefix ) {
    if( self->type == 1 ) node_hash__dump_to_makefile( (node_hash *) self, prefix );
    else {
        printf("\"");
        if( self->type == 2 ) printf("%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
        //else if( self->type == 3 ) node_arr__dump_to_makefile( (node_arr *) self, 0 );
        else if( self->type == 4 ) printf("%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
        else if( self->type == 5 ) printf("-%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
        else if( self->type == 6 ) printf("true");
        else if( self->type == 7 ) printf("false");
        else if( self->type == 8 ) printf("false");
        else if( self->type == 9 ) printf("%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
        printf("\"\n");
    }
}

void jnode__dump_env( jnode *self ) {
    printf("\"");
    if( self->type == 2 ) printf("%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    else if( self->type == 4 ) printf("%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    else if( self->type == 5 ) printf("-%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    else if( self->type == 6 ) printf("true");
    else if( self->type == 7 ) printf("false");
    else if( self->type == 8 ) printf("null");
    else if( self->type == 9 ) printf("%.*s", (int)( (node_str *) self )->len, ( (node_str *) self )->str );
    printf("\"");
}

void node_hash__store( node_hash *self, char *key, long keyLen, jnode *node ) {
    string_tree__store_len( self->tree, key, keyLen, (void *) node, 0 );
}

jnode *node_hash__get( node_hash *self, char *key, long keyLen ) {
    long type;
    return (jnode *) string_tree__get_len( self->tree, key, keyLen, &type );
}

char *node_hash__get_str( node_hash *self, char *key, long keyLen ) {
    long type;
    jnode *node = (jnode *) string_tree__get_len( self->tree, key, keyLen, &type );
    if( !node ) return NULL;
    if( node->type != 2 ) return NULL;
    node_str *nodeStr = (node_str *) node;
    char *buffer = malloc( nodeStr->len + 1 );
    sprintf( buffer, "%.*s", (int)nodeStr->len, nodeStr->str );
    return buffer;
}

uint8_t hexlet( char let ) {
    if( let >= '0' && let <= '9' ) return let - '0';
    if( let >= 'A' && let <= 'F' ) return let - 'A' + 10;
    if( let >= 'a' && let <= 'f' ) return let - 'a' + 10;
    return 0;
}

char *node_hash__get_str_escapes( node_hash *self, char *key, long keyLen ) {
    long type;
    jnode *node = (jnode *) string_tree__get_len( self->tree, key, keyLen, &type );
    if( !node ) return NULL;
    if( node->type != 2 ) return NULL;
    node_str *nodeStr = (node_str *) node;
    long len = nodeStr->len;
    char *str = nodeStr->str;
    char *buffer = malloc( len + 1 );
    int i=0;
    int dest=0;
    for( ;i<len;i++,dest++ ) {
        char let = str[i];
        if( let == '\\' ) {
            char next = str[++i];
            if( next == 'u' ) {
                uint32_t byte = 0;
                
                byte += hexlet( str[++i] );
                byte *= 16;
                
                byte += hexlet( str[++i] );
                byte *= 16;
                
                byte += hexlet( str[++i] );
                byte *= 16;
                
                byte += hexlet( str[++i] );
                
                if( byte < 256 ) {
                    buffer[ dest ] = byte;
                }
            }
            else buffer[dest]=next;
            continue;
        }
        buffer[dest] = let;
    }
    buffer[dest] = 0x00;
    return buffer;
}

int node_hash__get_int( node_hash *self, char *key, long keyLen ) {
    long type;
    jnode *node = string_tree__get_len( self->tree, key, keyLen, &type );
    if( !node ) return -1;
    if( node->type == 2 || node->type == 4 || node->type == 5 ) {
        node_str *nodeStr = (node_str *) node;
        char buffer[50];
        sprintf(buffer,"%.*s",(int)nodeStr->len,nodeStr->str);
        int val = atoi( buffer );
        if( node->type == 5 ) return -val;
        return val;
    }
    return -1;
}

double node_hash__get_double( node_hash *self, char *key, long keyLen ) {
    long type;
    jnode *node = string_tree__get_len( self->tree, key, keyLen, &type );
    if( !node ) return -1;
    if( node->type == 9 || node->type == 10 ) {
        node_str *nodeStr = (node_str *) node;
        char buffer[50];
        sprintf(buffer,"%.*s",(int)nodeStr->len,nodeStr->str);
        double val = atof( buffer );
        if( node->type == 10 ) return -val;
        return val;
    }
    return -1;
}

char nullStr[2] = { 0, 0 };

typedef struct handle_res_s {
    long dest;
    jnode *node;
} handle_res;

handle_res *handle_res__new(void) {
    handle_res *self = ( handle_res * ) calloc( sizeof( handle_res ), 1 );
    return self;
}

handle_res *handle_true( char *data, long *pos ) {
    jnode *node = jnode__new( 6 );
    handle_res *res = handle_res__new();
    res->node = node;
    return res;
}

handle_res *handle_false( char *data, long *pos ) {
    jnode *node = jnode__new( 7 );
    handle_res *res = handle_res__new();
    res->node = node;
    return res;
}

handle_res *handle_null( char *data, long *pos ) {
    jnode *node = jnode__new( 8 );
    handle_res *res = handle_res__new();
    res->node = node;
    return res;
}

typedef handle_res* (*ahandler)(char *, long * );

string_tree *handlers;
void ujsonin_init() {
    handlers = string_tree__new();
    string_tree__store_len( handlers, "true", 4, (void *) &handle_true, 0 );
    string_tree__store_len( handlers, "false", 5, (void *) &handle_false, 0 );
    string_tree__store_len( handlers, "null", 4, (void *) &handle_null, 0 );
}

node_hash *parse( char *data, long len, parser_state *beginState, int *err ) {
    long pos = 1, keyLen = 0, typeStart = 0;
    int endstate = 0;
    uint8_t neg = 0;
    char *keyStart = NULL, *strStart = NULL, let;
    
    node_hash *root = node_hash__new();
    jnode *cur = ( jnode * ) root;
    if( beginState ) {
        // If we start in the middle of a key or value, we must merge the previous value
        // This means we cannot start in the normal state; we must start in one capable of handling
        // the merge. The merge state needs to be able to handle that situation repeatedly also
        // in order to handle long values.
        switch( beginState->state ) {
            case 1: goto HashComment; // contents of a comment are discard
            case 2: goto HashComment2; // does matter as ending could be split between * and /
            case 3: goto QQKeyName1; 
            case 4: goto QQKeyNameX; // double quoted key
            case 5: goto QKeyName1; 
            case 6: goto QKeyNameX; // single quoted key
            case 7: goto KeyName1; 
            case 8: goto KeyNameX; // unquoted key
            case 9: goto Colon;
            case 10: goto AfterColon;
            case 11: goto TypeX; // capture of a named type ( true/false included )
            case 12: goto Arr;
            case 13: goto AC_Comment; // comments after : and before value
            case 14: goto AC_Comment2;
            case 15: goto Number1;
            case 16: goto NumberX;
            case 17: goto String1;
            case 18: goto StringX;
            case 19: goto AfterVal;
            case 20: goto AfterDot;
        }
    }
    
Hash: SAFE(0)
    let = data[pos++];
    if( let == '"' ) goto QQKeyName1;
    if( let == '\'' ) goto QKeyName1;
    if( let >= 'a' && let <= 'z' ) { pos--; goto KeyName1; }
    if( let == '}' && cur->parent ) cur = cur->parent;
    if( let == '/' && pos < (len-1) ) {
        if( data[pos] == '/' ) { pos++; goto HashComment; }
        if( data[pos] == '*' ) { pos++; goto HashComment2; }
    }
    goto Hash;
HashComment: SAFEGET(1)
    if( let == 0x0d || let == 0x0a ) goto Hash;
    goto HashComment;
HashComment2: SAFEGET(2)
    if( let == '*' && pos < (len-1) && data[pos] == '/' ) { pos++; goto Hash; }
    goto HashComment2;
QQKeyName1: SAFE(3)
    let = data[pos];
    keyStart = &data[pos++];
    if( let == '\\' ) pos++;
QQKeyNameX: SAFEGET(4)
    if( let == '\\' ) { pos++; goto QQKeyNameX; }
    if( let == '"' ) {
        keyLen = &data[pos-1] - keyStart;
        goto Colon;
    }
    goto QQKeyNameX;
QKeyName1: SAFE(5)
    let = data[pos];
    keyStart = &data[pos++];
    if( let == '\\' ) pos++;
QKeyNameX: SAFEGET(6)
    if( let == '\\' ) { pos++; goto QKeyNameX; }
    if( let == '\'' ) {
        keyLen = &data[pos-1] - keyStart;
        goto Colon;
    }
    goto QKeyNameX;
KeyName1: SAFE(7)
    keyStart = &data[pos++];
KeyNameX: SAFEGET(8)
    if( let == ':' ) {
        keyLen = &data[pos-1] - keyStart;
        goto AfterColon;
    }
    if( let == ' ' || let == '\t' ) {
        keyLen = &data[pos-1] - keyStart;
        goto Colon;
    }
    goto KeyNameX;
Colon: SAFEGET(9)
    if( let == ':' ) goto AfterColon;
    goto Colon;
AfterColon: SAFEGET(10)
    if( let == '"' ) goto String1;
    if( let == '{' ) {
        node_hash *newHash = node_hash__new();
        newHash->parent = cur;
        if( cur->type == 1 ) node_hash__store( (node_hash *) cur, keyStart, keyLen, (jnode *) newHash );
        if( cur->type == 3 ) node_arr__add( (node_arr *) cur, (jnode *) newHash );
        cur = (jnode *) newHash;
        goto Hash;
    }
    if( let >= 'a' && let <= 'z' ) {
        typeStart = pos - 1;
        goto TypeX;
    }
    if( let == '/' && pos < (len-1) ) {
        if( data[pos] == '/' ) { pos++; goto AC_Comment; }
        if( data[pos] == '*' ) { pos++; goto AC_Comment2; }
    }
    // if( let == 't' || let == 'f' ) ... for true/false
    if( let >= '0' && let <= '9' ) { neg=0; goto Number1; }
    if( let == '-' ) { neg=1; pos++; goto Number1; }
    if( let == '[' ) {
        node_arr *newArr = node_arr__new();
        newArr->parent = cur;
        if( cur->type == 1 ) node_hash__store( (node_hash *) cur, keyStart, keyLen, (jnode *) newArr );
        if( cur->type == 3 ) node_arr__add( (node_arr *) cur, (jnode *) newArr );
        cur = (jnode *) newArr;
        goto AfterColon;
    }
    if( let == ']' ) {
        cur = cur->parent;
        if( !cur ) goto Error;
        if( cur->type == 3 ) goto AfterColon;
        if( cur->type == 1 ) goto Hash;
        // should never reach here
    }
    goto AfterColon;
TypeX: SAFEGET(11)
    if( ( let >= '0' && let <= 9 ) || ( let >= 'a' && let <= 'z' ) ) goto TypeX;
    pos--; // go back a character; we've encountered a non-type character
    // Type name is done
    long typeLen = pos - typeStart;
    // do something with the type
    long htype;
    ahandler handler = (ahandler) string_tree__get_len( handlers, &data[ typeStart ], typeLen, &htype );
    if( handler == NULL ) {
        printf("disaster");
        exit(1);
    }
    handle_res *res = (*handler)( data, &pos );
    if( res == NULL ) {
        printf("disaster");
        exit(1);
    }
    if( res->dest == 0 ) {
        if( cur->type == 1 ) {
            node_hash__store( (node_hash *) cur, keyStart, keyLen, res->node );
            goto AfterVal;
        }
        if( cur->type == 3 ) {
            node_arr__add( (node_arr *) cur, res->node );
            goto AfterColon;
        }
    }
    goto TypeX; // should never reach here
/*AfterType: SAFEGET
    if( let == '.' ) goto GotDot;
    // skip whitespace till .
    if( let == ' ' || let == 0x0d || let == 0x0a || let == '\t' ) goto AfterType;
    // something else. garbage. :(
    goto AfterType;*/
Arr: SAFEGET(12)
    // TODO: stack of array tails
    if( let == ']' ) {
        goto AfterVal;
    }
    goto Arr;
AC_Comment: SAFEGET(13)
    if( let == 0x0d || let == 0x0a ) goto AfterColon;
    goto AC_Comment;
AC_Comment2: SAFEGET(14)
    if( let == '*' && pos < (len-1) && data[pos] == '/' ) { pos++; goto Hash; }
    goto AC_Comment2;
Number1: SAFE(15)
    strStart = &data[pos-1];
NumberX: SAFEGET(16)
    if( let == '.' ) { pos++; goto AfterDot; }
    if( let < '0' || let > '9' ) {
        long strLen = &data[pos-1] - strStart;
        jnode *newStr = (jnode *) node_str__new( strStart, strLen, neg ? 5 : 4 );
        if( cur->type == 1 ) {
            node_hash__store( (node_hash *) cur, keyStart, keyLen, newStr );
            goto AfterVal;
        }
        if( cur->type == 3 ) {
            node_arr__add( (node_arr *) cur, newStr );
            goto AfterColon;
        }
    }
    goto NumberX;
AfterDot: SAFEGET(20)
    if( let < '0' || let > '9' ) {
        long strLen = &data[pos-1] - strStart;
        jnode *newStr = (jnode *) node_str__new( strStart, strLen, neg ? 10 : 9 );
        if( cur->type == 1 ) {
            node_hash__store( (node_hash *) cur, keyStart, keyLen, newStr );
            goto AfterVal;
        }
        if( cur->type == 3 ) {
            node_arr__add( (node_arr *) cur, newStr );
            goto AfterColon;
        }
    }
    goto AfterDot;
String1: SAFEGET(17)
    if( let == '"' ) {
        jnode *newStr = (jnode *) node_str__new( nullStr, 0, 2 );
        if( cur->type == 1 ) {
            node_hash__store( (node_hash *) cur, keyStart, keyLen, newStr );
            goto AfterVal;
        }
        if( cur->type == 3 ) {
            node_arr__add( (node_arr *) cur, newStr );
            goto AfterColon;
        }
        goto AfterVal; // Should never be reached
    }
    strStart = &data[pos-1];
    if( let == '\\' ) pos++;
StringX: SAFEGET(18)
    if( let == '"' ) {
       long strLen = &data[pos-1] - strStart;
       jnode *newStr = (jnode *) node_str__new( strStart, strLen, 2 );
       if( cur->type == 1 ) {
           node_hash__store( (node_hash *) cur, keyStart, keyLen, newStr );
           goto AfterVal;
       }
       if( cur->type == 3 ) {
           node_arr__add( (node_arr *) cur, newStr );
           goto AfterColon;
       }
       goto AfterVal; // should never be reached
    }
    if( let == '\\' ) pos++;
    goto StringX;   
AfterVal: SAFE(19)
    // who cares about commas in between things; we can just ignore them :D
    goto Hash;
Error:
    // todo
Done:
    return root;
}
