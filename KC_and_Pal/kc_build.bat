COPY kc_and_pal.a48 C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\kc-and-pal-o2\aswcurr\bin\kc_and_pal.a48
CD C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\kc-and-pal-o2\aswcurr\bin
asw kc_and_pal.a48
p2bin kc_and_pal.p kc_and_pal.bin -r 1024-3071
COPY kc_and_pal.bin C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Dev_Resources\o2em118win\ROMS\kc_and_pal.bin
del kc_and_pal.a48, kc_and_pal.p, kc_and_pal.bin
CD C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Dev_Resources\o2em118win\
o2em kc_and_pal.bin -svolume=1
CD C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\kc-and-pal-o2\KC_and_Pal