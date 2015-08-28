#version 3 - if Password is encrypted, Data is encrypted as well
#version 4 - add Password Extension

import socket
import time
import sys
import getopt
import aes



RCVR_buf = [0] * 64
RCVR_buf_str = []
#-------------------------------------------------------------------------
def check_input_params(argv):
    SSID = ''                 # Symbolic name meaning the local host
    HOST = ''
    PASSWORD = ''
    DATA = ''
    USE_ENC = '0'

    if len(sys.argv) < 5:
        print "usage: " + sys.argv[0] + "  \n -s <ssid> \n -a <ip> \n -p <password> (-p open : no passowrd) \n -d <string> (-d none : no private data) \n     Note: example to pass 2 tokens 3+4 (-d \\x03\\x06qwerty\\x04\\x05abcde) \n -e (use encryption: 1 / 0)"
        sys.exit(2)

    try:
        opts, args = getopt.getopt(argv,"hs:a:p:d:e:")
    except getopt.GetoptError:
        print "usage: " + sys.argv[0] + "  -s <ssid> \n -a <ip> \n -p <password> (-p open : no passowrd) \n -d <string> (-d none : no private data) \n -e (use encryption)"
        sys.exit(2)


    for opt, arg in opts:
        if opt == '-h':
            print sys.argv[0] + "  -s <ssid> -k -a <ip> -p <password> (-p open : no passowrd)  -d <string> (-d none : no private data) -e (use encryption)"
            sys.exit()
        elif opt in ("-s"):
            SSID = arg
        elif opt in ("-a"):
            HOST = arg
            if HOST == '':
                print "remote  IP address is empty"
                sys.exit()
        elif opt in ("-p"):
            PASSWORD = arg
            print "Password is: " + PASSWORD
        elif opt in ("-d"):
            DATA = arg.decode("string_escape")  #can be text ("qwerty") or with index and length ("\x03\x06qwerty")
        elif opt in ("-e"):
            USE_ENC = arg
            if USE_ENC == '1':
                print "Use Encryption"
            else:
                print "Do not use Encryption"


    return(SSID,HOST,PASSWORD, DATA, USE_ENC)
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
def recover_cfg_buf(idx, curr_val):

    curr_idx = curr_val >> 4

    if(curr_idx % 2):
        RCVR_buf[curr_idx>>1] = RCVR_buf[curr_idx>>1] | (curr_val & 0x0f)
        RCVR_buf_str.append (chr(RCVR_buf[curr_idx>>1]))
    else:
        RCVR_buf[curr_idx>>1] = RCVR_buf[curr_idx>>1] | ((curr_val & 0x0f) << 4)

    return(RCVR_buf)
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
def tcp_client(ip, ssid, key, data, key_ext, use_enc):
    LOCAL_PORT = 15000              # Arbitrary non-privileged port


# FTC phase II defintions
    #Tokens
    t_start             = 1099      #ssid
    t_middle            = 1199      #password (1199 - password is not encrypted, 1200 password is encrypted by AES)
    t_private			= 1149      #data (private token)
    t_key_ext           = 1155      #password extension
    const_data_offset   =  593

    #ssid_id             =   0
    ssid_pwd_offset_1   =   1
    ssid_pwd_offset_2   =  27

    # strings for sync_phase 1
    #LOW_BIN
    data67 = "abc"
    #HIGH_BIN
    data87 = "abcdefghijklmnopqrstuvw"

    #to simulate IP option = 2, add 2 to: BINs + Tokes + Data offset + ssid+pwd_offset
    #LOW_BIN + 2
    #data67 = "abc12"
    #HIGH_BIN + 2
    #data87 = "abcdefghijklmnopqrstuvw12"


    #HIGH_BIN -5 (group ID #5)
#    data87 = "abcdefghijklmnopqr"

    print "-----------------"
    print "run udp client"
    print "-----------------"

# UDP  socket create
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    print "connected to " + " remote ip="+ ip + " remote port="+ str(LOCAL_PORT)

# prepare a string of length 1600
    i = 0
    string = '1'
    while i < 1600:
        string = string + '1'
        i += 1


# prepare FTC string
# 1) t_start
# 2) SSID length
# 3) SSID
# 4) t_middle
# 5) Password length
# 6) Password
# 7) t_private
# 8) private token length
# 9) private token
# 10) t_pwd_ext
# 11) password extension length
# 12) password extension

# build SSID length  for cfg string
    ssid_len    =  len(ssid)
    ssid_len    += (ssid_pwd_offset_1 + ssid_pwd_offset_2)


# if key string  is "open" , there is no key
    if key == "open":
        key = []
        key_ext = []
    else:       #if key exist and encryption is applied, increment the token
        if use_enc == '1':
            t_middle += 1

# build KEY length  for cfg string
    key_len      = len(key)
    key_len     += (ssid_pwd_offset_1 + ssid_pwd_offset_2)

# build KEY length  for cfg string
    key_ext_len      = len(key_ext)
    key_ext_len     += (ssid_pwd_offset_1 + ssid_pwd_offset_2)

# if data string  is "none" , there is no data
    if data == "none":
        data = []

# build Data length  for cfg string
    data_len      = len(data)
    data_len     += (ssid_pwd_offset_1 + ssid_pwd_offset_2)

# -----------------------
# Prepare SSID string
# -----------------------
    i           = 0
    running_idx = 0

    NibbleHigh = ord(ssid[i])/16
    FTC_string = [NibbleHigh+const_data_offset]
    running_idx = (running_idx + 1) % 16
    NibbleLow = ord(ssid[i])%16
    FTC_string = FTC_string + [(16*(running_idx ^ NibbleHigh)) + NibbleLow + const_data_offset]
    running_idx = (running_idx + 1) % 16
    i += 1

    while i < len(ssid):
        NibbleHigh = ord(ssid[i])/16
        FTC_string = FTC_string + [(16*(running_idx ^ NibbleLow))+NibbleHigh+const_data_offset]
        running_idx = (running_idx + 1) % 16
        NibbleLow = ord(ssid[i])%16
        FTC_string = FTC_string + [(16*(running_idx ^ NibbleHigh))+NibbleLow+const_data_offset]
        running_idx = (running_idx + 1) % 16
        i += 1

# -----------------------
# Prepare Pasword string
# -----------------------
    if len(key) != 0:
        i = 0
        running_idx = 0

        NibbleHigh = ord(key[i])/16
        FTC_string1 = [NibbleHigh+const_data_offset]
        running_idx = (running_idx + 1) % 16
        NibbleLow = ord(key[i])%16
        FTC_string1 = FTC_string1 + [(16*(running_idx ^ NibbleHigh)) + NibbleLow + const_data_offset]
        running_idx = (running_idx + 1) % 16
        i += 1

        while i < len(key):
            NibbleHigh = ord(key[i])/16
            FTC_string1 = FTC_string1 + [(16*(running_idx ^ NibbleLow))+NibbleHigh+const_data_offset]
            running_idx = (running_idx + 1) % 16
            NibbleLow = ord(key[i])%16
            FTC_string1 = FTC_string1 + [(16*(running_idx ^ NibbleHigh))+NibbleLow+const_data_offset]
            running_idx = (running_idx + 1) % 16
            i += 1
    else:
       FTC_string1 = []

# -----------------------
# Prepare Data string
# -----------------------
    if len(data) != 0:
	    i           = 0
	    running_idx = 0

	    NibbleHigh = ord(data[i])/16
	    FTC_string2 = [NibbleHigh+const_data_offset]
	    running_idx = (running_idx + 1) % 16
	    NibbleLow = ord(data[i])%16
	    FTC_string2 = FTC_string2 + [(16*(running_idx ^ NibbleHigh)) + NibbleLow + const_data_offset]
	    running_idx = (running_idx + 1) % 16
	    i += 1

	    while i < len(data):
	        NibbleHigh = ord(data[i])/16
	        FTC_string2 = FTC_string2 + [(16*(running_idx ^ NibbleLow))+NibbleHigh+const_data_offset]
	        running_idx = (running_idx + 1) % 16
	        NibbleLow = ord(data[i])%16
	        FTC_string2 = FTC_string2 + [(16*(running_idx ^ NibbleHigh))+NibbleLow+const_data_offset]
	        running_idx = (running_idx + 1) % 16
	        i += 1
    else:
        FTC_string2 = []

# --------------------------------
# Prepare Pasword Extension string
# --------------------------------
    if len(key_ext) != 0:
        i = 0
        running_idx = 0

        NibbleHigh = ord(key_ext[i])/16
        FTC_string3 = [NibbleHigh+const_data_offset]
        running_idx = (running_idx + 1) % 16
        NibbleLow = ord(key_ext[i])%16
        FTC_string3 = FTC_string3 + [(16*(running_idx ^ NibbleHigh)) + NibbleLow + const_data_offset]
        running_idx = (running_idx + 1) % 16
        i += 1

        while i < len(key_ext):
            NibbleHigh = ord(key_ext[i])/16
            FTC_string3 = FTC_string3 + [(16*(running_idx ^ NibbleLow))+NibbleHigh+const_data_offset]
            running_idx = (running_idx + 1) % 16
            NibbleLow = ord(key_ext[i])%16
            FTC_string3 = FTC_string3 + [(16*(running_idx ^ NibbleHigh))+NibbleLow+const_data_offset]
            running_idx = (running_idx + 1) % 16
            i += 1
    else:
       FTC_string3 = []



    name = raw_input("\n\nPress any key to start sending confgiguration string ....")


    loop_err_idx = 1
    loop = 1
    udp_addr = (ip, LOCAL_PORT)

	#tranmist SSID + Password + Data in loop
    while loop:

	#SSID String
        s.sendto(data67,udp_addr)
        s.sendto(string[0:t_start], udp_addr)
        s.sendto(data87,udp_addr)
        s.sendto(string[0:ssid_len],udp_addr)
        s.sendto(data67,udp_addr)

        i = 0
        for character in FTC_string:
            s.sendto(string[0:FTC_string[i]],udp_addr)
            if (i % 2):
                s.sendto(data87,udp_addr)
            else:
                s.sendto(data67,udp_addr)
            i = i + 1

	#PASSWORD String
        s.sendto(data87,udp_addr)
        s.sendto(string[0:t_middle],udp_addr)
        s.sendto(data67,udp_addr)
        s.sendto(string[0:key_len],udp_addr)
        s.sendto(data87,udp_addr)

        i = 0
        for character in FTC_string1:
            s.sendto(string[0:FTC_string1[i]],udp_addr)
            if (i % 2):
                s.sendto(data87,udp_addr)
            else:
                s.sendto(data67,udp_addr)
            i = i + 1

	#Data String
        s.sendto(data67,udp_addr)
        s.sendto(string[0:t_private], udp_addr)
        s.sendto(data87,udp_addr)
        s.sendto(string[0:data_len],udp_addr)
        s.sendto(data67,udp_addr)

        i = 0
        for character in FTC_string2:
            s.sendto(string[0:FTC_string2[i]],udp_addr)
            if (i % 2):
                s.sendto(data87,udp_addr)
            else:
                s.sendto(data67,udp_addr)
            i = i + 1

	#PASSWORD Extension String
        s.sendto(data87,udp_addr)
        s.sendto(string[0:t_key_ext],udp_addr)
        s.sendto(data67,udp_addr)
        s.sendto(string[0:key_ext_len],udp_addr)
        s.sendto(data87,udp_addr)

        i = 0
        for character in FTC_string3:
            s.sendto(string[0:FTC_string3[i]],udp_addr)
            if (i % 2):
                s.sendto(data87,udp_addr)
            else:
                s.sendto(data67,udp_addr)
            i = i + 1

#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
if __name__ == '__main__':
#    ssid,ip,key_str = check_input_params(sys.argv[1:])
    ssid,ip,password,data, use_enc = check_input_params(sys.argv[1:])

    key_str  = ''
    data_str = ''
    key_ext_str = ''

    if data == "none":
        print "NO Private Data"
        data_str = "none"

    if password == "open":
        print "NO security"
        key_str = "open"

#if no encryption, take strings as is
    if use_enc == '0':
        key_str     = password[0:32]      #take first 32 bytes as is
        key_ext_str = password[32:]       #takelast 32 bytes as is
        data_str    = data
################################################################################
#Start of Encryption procedure
################################################################################
    else:

        if password == "open":
            print "cannot encrypt since no password was supplied !!!"
            exit

        moo = aes.AESModeOfOperation()

#first byte is the length of the password (unless password length is 32 bytes)
        password_input = password
        if (len(password) < 32):
            password = chr(len(password_input)) + password_input    #add length of password
            password_ext = []
        elif (len(password) == 32):     #taske as is
            password = password_input
            password_ext = []
        elif (len(password) < 64):
            password     = password_input[0:32]     #take first 32 bytes as is
            password_ext = password_input[32:]      #take rest of bytes
            password_ext = chr(len(password_ext)) + password_ext    #add length of  extension
        elif (len(password) == 64):
            password     = password_input[0:32]     #take first 32 bytes as is
            password_ext = password_input[32:64]    #take last  32 bytes as is

        #padd with zeros
        while len(password) < 32:
	       password = password + '\0'

        password1 = password[0:16]
        password2 = password[16:32]

        #padd extension with zeros (if exist)
        if (len(password_ext) > 0):
            while len(password_ext) < 32:
	           password_ext = password_ext + '\0'

            password_ext1 = password_ext[0:16]
            password_ext2 = password_ext[16:32]


#padd the data with 0xFF if less than 32 chars
        if data != "none":
            if (len(data) < 32):
                while len(data) < 32:
                    data = data +  '\xFF'

            data1 = data[0:16]
            data2 = data[16:32]
################################################################################

#print password

#        print len(password)
#        print len(password1)
#        print len(password2)

        i = 0
        print "Passowrd [0-31]:"
        while i < 16:
            sys.stdout.write(hex(ord(password1[i])))
            i = i + 1
            sys.stdout.write('\n')

        i = 0
        while i < 16:
            sys.stdout.write(hex(ord(password2[i])))
            i = i + 1
            sys.stdout.write('\n')

#####################
# Password Encryption
#####################

        #encrypt 16 bytes - password[0:15]
        mode,orig_len,cipherOut1 = moo.encrypt(password1,
                                               moo.modeOfOperation["OFB"],
                                               [115,109,97,114,116,99,111,110,102,105,103,65,69,83,49,54],
                                               moo.aes.keySize["SIZE_128"],
                                               [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1])

        #encrypt 16 bytes - password[16:31]
        mode,orig_len,cipherOut2 = moo.encrypt(password2,
                                               moo.modeOfOperation["OFB"],
                                               [115,109,97,114,116,99,111,110,102,105,103,65,69,83,49,54],
                                               moo.aes.keySize["SIZE_128"],
                                               [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1])

        cipherOutFull 	  = cipherOut1 + cipherOut2
################################################################################

#print data

        if data != "none":
            print "Data [0-31]:"
            i = 0
            while i < 16:
                sys.stdout.write(hex(ord(data1[i])))
                i = i + 1
                sys.stdout.write('\n')

            i = 0
            while i < 16:
                sys.stdout.write(hex(ord(data2[i])))
                i = i + 1
                sys.stdout.write('\n')

#################
# Data Encryption
#################

            #encrypt 16 bytes - data[0:15]
            mode,orig_len,cipherOut3 = moo.encrypt(data1,
                                                   moo.modeOfOperation["OFB"],
                                                   [115,109,97,114,116,99,111,110,102,105,103,65,69,83,49,54],
                                                   moo.aes.keySize["SIZE_128"],
                                                   [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1])

            #encrypt 16 bytes - data[16:31]
            mode,orig_len,cipherOut4 = moo.encrypt(data2,
                                                   moo.modeOfOperation["OFB"],
                                                   [115,109,97,114,116,99,111,110,102,105,103,65,69,83,49,54],
                                                   moo.aes.keySize["SIZE_128"],
                                                   [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1])

            cipherOutFullData = cipherOut3 + cipherOut4
################################################################################
#print password extension

        if (len(password_ext) > 0):
            print "Passowrd [32-63]:"
            i = 0
            while i < 16:
                sys.stdout.write(hex(ord(password_ext1[i])))
                i = i + 1
                sys.stdout.write('\n')

            i = 0
            while i < 16:
                sys.stdout.write(hex(ord(password_ext2[i])))
                i = i + 1
                sys.stdout.write('\n')

###############################
# Password Extension Encryption
###############################

            #encrypt 16 bytes - password_ext[0:15]
            mode,orig_len,cipherOut5 = moo.encrypt(password_ext1,
                                                   moo.modeOfOperation["OFB"],
                                                   [115,109,97,114,116,99,111,110,102,105,103,65,69,83,49,54],
                                                   moo.aes.keySize["SIZE_128"],
                                                   [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1])

            #encrypt 16 bytes - password_ext[16:31]
            mode,orig_len,cipherOut6 = moo.encrypt(password_ext2,
                                                   moo.modeOfOperation["OFB"],
                                                   [115,109,97,114,116,99,111,110,102,105,103,65,69,83,49,54],
                                                   moo.aes.keySize["SIZE_128"],
                                                   [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1])

            cipherOutFullPwdExt 	  = cipherOut5 + cipherOut6
################################################################################

        i = 0
        j = 0
        k = 0
#print encrypted password
        print "Encrypted Password [0-31]: \n"
        for x in cipherOutFull:
            sys.stdout.write(hex(x))
            i+=1
            if i % 4 == 0:
                print ("\n")

            sys.stdout.write('\n')

#print encrypted password extension
        if (len(password_ext) > 0):
            print "Encrypted Password Extension [0-31]: \n"
            for x in cipherOutFullPwdExt:
                sys.stdout.write(hex(x))
                k+=1
                if k % 4 == 0:
                    print ("\n")

                sys.stdout.write('\n')

#print encrypted data
        if data != "none":
            print "Encrypted Data [0-31]: \n"
            for x in cipherOutFullData:
                sys.stdout.write(hex(x))
                j+=1
                if j % 4 == 0:
                    print ("\n")

                sys.stdout.write('\n')

################################################################################

#convert password to string
        for i in range(len(cipherOutFull)):
            key_str = key_str + chr(cipherOutFull[i])
#convert data to string
        if data != "none":
            for j in range(len(cipherOutFullData)):
                data_str = data_str + chr(cipherOutFullData[j])
#convert password extension to string
        if (len(password_ext) > 0):
            for k in range(len(cipherOutFullPwdExt)):
                key_ext_str = key_ext_str + chr(cipherOutFullPwdExt[k])

################################################################################

    tcp_client(ip, ssid, key_str, data_str, key_ext_str, use_enc)

