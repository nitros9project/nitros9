* sky_stars.d - written by tools/flightsim2/stars_gen.py from the Yale Bright Star Catalog (BSC5): do not edit.
* 422 stars brighter than V 4.0 that rise at 42 deg north, brightest first: equatorial unit vectors x 127
* (x toward RA 0h, y toward RA 6h, z the north celestial pole), three signed bytes a star.
SkNBright           equ       15                V < 1.5: white, shown from dusk
SkNMid              equ       139               V < 3.0 (gray, at night)
SkN                 equ       422               V < 4.0 (dark gray, at night): all of them
* SkLst: the sidereal time at local midnight (CST, 87.9 W) on each season's mid-date, 65536 = 24 h
SkLst               fdb       $5310,$9225,$D1ED,$1269
SkTab               equ       *
                    fcb       -24,119,-37   * V -1.46 9Alp CMa
                    fcb       -100,-67,42   * V -0.04 16Alp Boo
                    fcb       16,-98,80     * V 0.03 3Alp Lyr
                    fcb       17,87,91      * V 0.08 13Alp Aur
                    fcb       25,123,-18    * V 0.12 19Bet Ori
                    fcb       -53,115,12    * V 0.38 10Alp CMi
                    fcb       3,126,16      * V 0.50 58Alp Ori
                    fcb       58,-111,20    * V 0.77 53Alp Aql
                    fcb       44,114,36     * V 0.85 87Alp Tau
                    fcb       -44,-105,-57  * V 0.96 21Alp Sco
                    fcb       -116,-45,-25  * V 0.98 67Alp Vir
                    fcb       -50,100,60    * V 1.14 78Bet Gem
                    fcb       106,-30,-63   * V 1.16 24Alp PsA
                    fcb       58,-68,90     * V 1.25 50Alp Cyg
                    fcb       -110,58,26    * V 1.35 32Alp Leo
                    fcb       -28,107,-62   * V 1.50 21Eps CMa
                    fcb       -12,-101,-77  * V 1.63 35Lam Sco
                    fcb       19,125,14     * V 1.64 24Gam Ori
                    fcb       16,110,61     * V 1.65 112Bet Tau
                    fcb       13,126,-3     * V 1.70 46Eps Ori
                    fcb       77,-41,-93    * V 1.74 Alp Gru
                    fcb       -69,-17,105   * V 1.77 77Eps UMa
                    fcb       -46,73,-93    * V 1.78 Gam2Vel
                    fcb       51,64,97      * V 1.79 33Alp Per
                    fcb       -58,15,112    * V 1.79 50Alp UMa
                    fcb       -33,109,-56   * V 1.84 25Del CMa
                    fcb       11,-104,-72   * V 1.85 20Eps Sgr
                    fcb       -74,-37,96    * V 1.86 85Eta UMa
                    fcb       -9,-92,-87    * V 1.87 The Sco
                    fcb       0,90,90       * V 1.90 34Bet Aur
                    fcb       -20,120,36    * V 1.93 24Gam Gem
                    fcb       -12,120,-39   * V 1.98 2Bet CMa
                    fcb       -43,99,67     * V 1.98 66Alp Gem
                    fcb       -99,77,-19    * V 1.98 30Alp Hya
                    fcb       99,61,51      * V 2.00 13Alp Ari
                    fcb       -57,-99,56    * V 2.00 
                    fcb       1,1,127       * V 2.02 1Alp UMi
                    fcb       27,-111,-56   * V 2.02 34Sig Sgr
                    fcb       119,23,-39    * V 2.04 16Bet Cet
                    fcb       11,126,-4     * V 2.05 50Zet Ori
                    fcb       111,4,62      * V 2.06 21Alp And
                    fcb       98,31,74      * V 2.06 43Bet And
                    fcb       7,125,-21     * V 2.06 53Kap Ori
                    fcb       -87,-54,-75   * V 2.06 5The Cen
                    fcb       -25,-24,122   * V 2.08 7Bet UMi
                    fcb       -14,-123,28   * V 2.08 55Alp Oph
                    fcb       82,-29,-93    * V 2.10 Bet Gru
                    fcb       65,70,83      * V 2.12 26Bet Per
                    fcb       -123,6,32     * V 2.14 94Bet Leo
                    fcb       56,-79,82     * V 2.20 37Gam Cyg
                    fcb       -67,63,-87    * V 2.21 Lam Vel
                    fcb       69,12,106     * V 2.23 18Alp Cas
                    fcb       15,126,-1     * V 2.23 34Del Ori
                    fcb       -67,-91,57    * V 2.23 5Alp CrB
                    fcb       -1,-79,99     * V 2.23 33Gam Dra
                    fcb       -50,83,-82    * V 2.25 Zet Pup
                    fcb       80,48,86      * V 2.26 57Gam1And
                    fcb       65,3,109      * V 2.27 11Bet Cas
                    fcb       -68,-26,104   * V 2.27 79Zet UMa
                    fcb       -31,-100,-72  * V 2.29 26Eps Sco
                    fcb       -65,-56,-93   * V 2.30 Alp Lup
                    fcb       -73,-59,-85   * V 2.31 Eta Cen
                    fcb       -58,-102,-49  * V 2.32 7Del Sco
                    fcb       -68,18,106    * V 2.37 48Bet UMa
                    fcb       93,11,-85     * V 2.39 Alp Phe
                    fcb       104,-70,22    * V 2.39 8Eps Peg
                    fcb       -8,-98,-80    * V 2.41 Kap Sco
                    fcb       109,-27,60    * V 2.42 53Bet Peg
                    fcb       -26,-119,-34  * V 2.43 35Eta Oph
                    fcb       -75,2,102     * V 2.44 64Gam UMa
                    fcb       45,-38,113    * V 2.44 5Alp Cep
                    fcb       -40,103,-62   * V 2.45 31Eta CMa
                    fcb       70,-79,71     * V 2.46 53Eps Cyg
                    fcb       60,15,111     * V 2.47 27Gam Cas
                    fcb       119,-29,33    * V 2.49 54Alp Peg
                    fcb       89,90,9       * V 2.53 92Alp Cet
                    fcb       -75,-42,-93   * V 2.55 Zet Cen
                    fcb       -117,24,45    * V 2.56 68Del Leo
                    fcb       -44,-117,-23  * V 2.56 13Zet Oph
                    fcb       14,120,-39    * V 2.58 11Alp Lep
                    fcb       -121,-8,-38   * V 2.59 4Gam Crv
                    fcb       30,-106,-63   * V 2.60 38Zet Sgr
                    fcb       -108,50,43    * V 2.61 41Gam1Leo
                    fcb       -82,-95,-21   * V 2.61 27Bet Lib
                    fcb       0,101,77      * V 2.62 37The Aur
                    fcb       -57,-105,-43  * V 2.62 8Bet1Sco
                    fcb       104,57,45     * V 2.64 6Bet Ari
                    fcb       9,105,-71     * V 2.64 Alp Col
                    fcb       -115,-17,-50  * V 2.65 9Bet Crv
                    fcb       -70,-105,14   * V 2.65 24Alp Ser
                    fcb       59,23,110     * V 2.68 37Del Cas
                    fcb       -106,-58,40   * V 2.68 8Eta Boo
                    fcb       -66,-65,-87   * V 2.68 Bet Lup
                    fcb       29,102,69     * V 2.69 3Iot Aur
                    fcb       -13,-100,-77  * V 2.69 34Ups Sco
                    fcb       -33,96,-77    * V 2.70 Pi  Pup
                    fcb       -85,-75,58    * V 2.70 36Eps Boo
                    fcb       10,-110,-63   * V 2.70 19Del Sgr
                    fcb       56,-112,23    * V 2.72 50Gam Aql
                    fcb       -56,-114,-8   * V 2.74 1Del Oph
                    fcb       -25,-55,112   * V 2.74 14Eta Dra
                    fcb       -96,-35,-76   * V 2.75 Iot Cen
                    fcb       -90,-83,-35   * V 2.75 9Alp2Lib
                    fcb       14,126,-13    * V 2.77 44Iot Ori
                    fcb       -45,-109,47   * V 2.77 27Bet Her
                    fcb       -9,-126,10    * V 2.77 60Bet Oph
                    fcb       -56,-77,-84   * V 2.78 Gam Lup
                    fcb       29,123,-11    * V 2.79 67Bet Eri
                    fcb       -10,-77,100   * V 2.79 23Bet Dra
                    fcb       -61,98,-52    * V 2.81 15Rho Pup
                    fcb       -36,-102,67   * V 2.81 40Zet Her
                    fcb       14,-114,-55   * V 2.81 22Lam Sgr
                    fcb       -40,-104,-60  * V 2.82 23Tau Sco
                    fcb       122,7,33      * V 2.83 88Gam Peg
                    fcb       -120,-33,24   * V 2.83 47Eps Vir
                    fcb       16,118,-45    * V 2.84 9Bet Lep
                    fcb       56,92,67      * V 2.85 44Zet Per
                    fcb       63,97,52      * V 2.87 25Eta Tau
                    fcb       40,-80,90     * V 2.87 18Del Cyg
                    fcb       102,-67,-35   * V 2.87 49Del Cap
                    fcb       -12,117,49    * V 2.88 13Mu  Gem
                    fcb       -43,99,67     * V 2.88 66Alp Gem
                    fcb       49,84,82      * V 2.89 45Eps Per
                    fcb       -58,-98,-56   * V 2.89 6Pi  Sco
                    fcb       -48,-104,-55  * V 2.89 20Sig Sco
                    fcb       36,-113,-46   * V 2.89 41Pi  Sgr
                    fcb       -47,117,18    * V 2.90 3Bet CMi
                    fcb       -97,-24,79    * V 2.90 12Alp2CVn
                    fcb       101,-76,-12   * V 2.91 22Bet Aqr
                    fcb       52,55,102     * V 2.93 23Gam Per
                    fcb       104,-36,64    * V 2.94 44Eta Peg
                    fcb       63,106,-30    * V 2.95 34Gam Eri
                    fcb       -121,-16,-36  * V 2.95 7Del Crv
                    fcb       112,-61,-1    * V 2.96 34Alp Aqr
                    fcb       -22,113,54    * V 2.98 27Eps Gem
                    fcb       -97,64,51     * V 2.98 17Eps Leo
                    fcb       23,89,88      * V 2.99 7Eps Aur
                    fcb       3,-109,-64    * V 2.99 10Gam2Sgr
                    fcb       35,-118,30    * V 2.99 17Zet Aql
                    fcb       88,56,73      * V 3.00 4Bet Tri
                    fcb       12,118,46     * V 3.00 123Zet Tau
                    fcb       -117,-5,-49   * V 3.00 2Eps Crv
                    fcb       -110,-39,-50  * V 3.00 46Gam Hya
                    fcb       48,71,94      * V 3.01 39Del Per
                    fcb       -88,20,89     * V 3.01 52Psi UMa
                    fcb       86,-53,-77    * V 3.01 Gam Gru
                    fcb       -10,109,-64   * V 3.02 1Zet CMa
                    fcb       -32,112,-51   * V 3.02 24Omi2CMa
                    fcb       -79,-61,79    * V 3.03 27Gam Boo
                    fcb       -5,-97,-82    * V 3.03 Iot1Sco
                    fcb       104,72,-7     * V 3.04 68Omi Cet
                    fcb       -83,-43,-86   * V 3.04 Mu  Cen
                    fcb       -87,39,84     * V 3.05 34Mu  UMa
                    fcb       -25,-30,121   * V 3.05 13Gam UMi
                    fcb       15,-46,117    * V 3.07 57Del Dra
                    fcb       -29,-96,-78   * V 3.08 Mu 1Sco
                    fcb       43,-104,60    * V 3.08 6Bet1Cyg
                    fcb       71,-100,-32   * V 3.08 9Bet Cap
                    fcb       -88,91,13     * V 3.11 16Zet Hya
                    fcb       -116,37,-35   * V 3.11 Nu  Hya
                    fcb       8,-101,-76    * V 3.11 Eta Sgr
                    fcb       55,-67,-93    * V 3.11 Alp Ind
                    fcb       4,103,-74     * V 3.12 Bet Col
                    fcb       -81,67,72     * V 3.13 40Alp Lyn
                    fcb       -67,-66,-85   * V 3.13 Kap Cen
                    fcb       -60,60,94     * V 3.14 9Iot UMa
                    fcb       -22,-113,53   * V 3.14 65Del Her
                    fcb       -20,-100,76   * V 3.16 67Pi  Her
                    fcb       22,93,84      * V 3.17 10Eta Aur
                    fcb       -15,91,-87    * V 3.17 Nu  Pup
                    fcb       -63,47,100    * V 3.17 25The UMa
                    fcb       -12,-51,116   * V 3.17 22Zet Dra
                    fcb       22,-111,-58   * V 3.17 27Phi Sgr
                    fcb       38,120,15     * V 3.19 1Pi 3Ori
                    fcb       28,114,-48    * V 3.19 2Eps Lep
                    fcb       -34,-121,21   * V 3.20 27Kap Oph
                    fcb       82,-73,64     * V 3.20 64Zet Cyg
                    fcb       -4,-101,-77   * V 3.21 
                    fcb       27,-2,124     * V 3.21 35Gam Cep
                    fcb       -61,-74,-83   * V 3.22 Del Lup
                    fcb       69,-107,-2    * V 3.23 65The Aql
                    fcb       33,-26,120    * V 3.23 8Bet Cep
                    fcb       69,68,-82     * V 3.24 The1Eri
                    fcb       -54,-114,-10  * V 3.24 2Eps Oph
                    fcb       27,-103,69    * V 3.24 14Gam Lyr
                    fcb       -35,86,-87    * V 3.25 Sig Pup
                    fcb       12,-126,-6    * V 3.26 58Eta Ser
                    fcb       107,19,65     * V 3.27 31Del And
                    fcb       -97,-59,-57   * V 3.27 49Pi  Hya
                    fcb       -19,-114,-54  * V 3.27 42The Oph
                    fcb       117,-34,-35   * V 3.27 76Del Aqr
                    fcb       -8,117,49     * V 3.28 7Eta Gem
                    fcb       -80,-83,-54   * V 3.29 20Sig Lib
                    fcb       -41,-51,109   * V 3.29 12Iot Dra
                    fcb       83,25,-92     * V 3.31 Bet Phe
                    fcb       25,119,-35    * V 3.31 5Mu  Lep
                    fcb       -69,-5,107    * V 3.31 69Del UMa
                    fcb       32,-108,-59   * V 3.32 40Tau Sgr
                    fcb       -19,-91,-87   * V 3.33 Eta Sco
                    fcb       -53,102,-53   * V 3.34 7Xi  Pup
                    fcb       -120,24,34    * V 3.34 70The Leo
                    fcb       -1,-125,-22   * V 3.34 64Nu  Oph
                    fcb       59,-31,108    * V 3.35 21Zet Cep
                    fcb       20,125,-5     * V 3.36 28Eta Ori
                    fcb       -24,121,28    * V 3.36 31Xi  Gem
                    fcb       -38,49,111    * V 3.36 1Omi UMa
                    fcb       46,-118,7     * V 3.36 30Del Aql
                    fcb       -116,-51,-1   * V 3.37 79Zet Vir
                    fcb       -57,-70,-89   * V 3.37 Eps Lup
                    fcb       49,27,114     * V 3.38 45Eps Cas
                    fcb       -84,94,14     * V 3.38 11Eps Hya
                    fcb       -123,-30,8    * V 3.38 43Del Vir
                    fcb       68,72,80      * V 3.39 25Rho Per
                    fcb       47,113,35     * V 3.40 78The2Tau
                    fcb       117,-42,24    * V 3.40 42Zet Peg
                    fcb       86,35,-87     * V 3.41 Gam Phe
                    fcb       97,52,63      * V 3.41 2Alp Tri
                    fcb       -84,-44,-84   * V 3.41 Nu  Cen
                    fcb       -50,-86,-79   * V 3.41 Eta Lup
                    fcb       -7,-112,59    * V 3.42 86Mu  Her
                    fcb       40,-45,112    * V 3.43 3Eta Cep
                    fcb       66,14,107     * V 3.44 24Eta Cas
                    fcb       -105,51,50    * V 3.44 36Zet Leo
                    fcb       36,-121,-11   * V 3.44 16Lam Aql
                    fcb       119,37,-22    * V 3.45 31Eta Cet
                    fcb       -84,40,86     * V 3.45 33Lam UMa
                    fcb       23,-104,70    * V 3.45 10Bet Lyr
                    fcb       96,83,7       * V 3.47 86Gam Cet
                    fcb       62,108,27     * V 3.47 35Lam Tau
                    fcb       -30,108,-59   * V 3.47 22Sig CMa
                    fcb       -70,-80,70    * V 3.47 49Del Boo
                    fcb       59,-104,42    * V 3.47 12Gam Sge
                    fcb       -105,19,69    * V 3.48 54Nu  UMa
                    fcb       -24,-121,32   * V 3.48 64Alp1Her
                    fcb       110,-35,53    * V 3.48 48Mu  Peg
                    fcb       110,54,-35    * V 3.50 52Tau Cet
                    fcb       -68,-69,82    * V 3.50 42Bet Boo
                    fcb       10,-88,-91    * V 3.51 Alp Tel
                    fcb       30,-115,-46   * V 3.51 37Xi 2Sgr
                    fcb       -70,104,20    * V 3.52 17Bet Cnc
                    fcb       -103,71,22    * V 3.52 14Omi Leo
                    fcb       -107,57,37    * V 3.52 30Eta Leo
                    fcb       49,-15,116    * V 3.52 32Iot Cep
                    fcb       47,111,42     * V 3.53 74Eps Tau
                    fcb       -40,111,48    * V 3.53 55Del Gem
                    fcb       -68,-107,-8   * V 3.53 32Mu  Ser
                    fcb       -33,-93,80    * V 3.53 44Eta Her
                    fcb       112,-58,14    * V 3.53 26The Peg
                    fcb       70,104,-22    * V 3.54 23Del Eri
                    fcb       14,124,22     * V 3.54 39Lam Ori
                    fcb       -107,13,-67   * V 3.54 Xi  Hya
                    fcb       -12,-122,-34  * V 3.54 55Xi  Ser
                    fcb       7,123,-32     * V 3.55 14Zet Lep
                    fcb       -72,-50,-91   * V 3.55 Iot Lup
                    fcb       125,11,-19    * V 3.56 8Iot Cet
                    fcb       45,95,-71     * V 3.56 41Ups4Eri
                    fcb       -121,22,-32   * V 3.56 12Del Crt
                    fcb       -65,-79,-75   * V 3.56 Phi1Lup
                    fcb       76,35,95      * V 3.57 51    And
                    fcb       -51,104,52    * V 3.57 77Kap Gem
                    fcb       -29,-96,-78   * V 3.57 Mu 2Sco
                    fcb       3,-38,121     * V 3.57 44Chi Dra
                    fcb       70,-102,-28   * V 3.57 6Alp2Cap
                    fcb       -41,115,36    * V 3.58 54Lam Gem
                    fcb       -86,-67,64    * V 3.58 25Rho Boo
                    fcb       -65,-91,-60   * V 3.58 39Ups Lib
                    fcb       117,45,-18    * V 3.60 45The Cet
                    fcb       79,98,20      * V 3.60 1Omi Tau
                    fcb       23,124,-15    * V 3.60 20Tau Ori
                    fcb       8,117,-48     * V 3.60 13Gam Lep
                    fcb       -24,103,71    * V 3.60 34The Gem
                    fcb       -62,60,93     * V 3.60 12Kap UMa
                    fcb       -77,59,-82    * V 3.60 Psi Vel
                    fcb       -44,90,-78    * V 3.61 
                    fcb       -110,57,-27   * V 3.61 41Lam Hya
                    fcb       -127,5,4      * V 3.61 5Bet Vir
                    fcb       113,48,34     * V 3.62 99Eta Psc
                    fcb       -26,-90,-86   * V 3.62 Zet2Sco
                    fcb       91,-24,86     * V 3.62 1Omi And
                    fcb       83,76,58      * V 3.63 41    Ari
                    fcb       63,98,52      * V 3.63 27    Tau
                    fcb       78,-95,32     * V 3.63 6Bet Del
                    fcb       52,111,34     * V 3.65 54Gam Tau
                    fcb       -125,-23,-3   * V 3.65 29Gam Vir
                    fcb       -47,-28,115   * V 3.65 11Alp Dra
                    fcb       74,12,103     * V 3.66 17Zet Cas
                    fcb       -64,-90,-63   * V 3.66 40Tau Lib
                    fcb       116,-26,-46   * V 3.66 88    Aqr
                    fcb       -46,35,113    * V 3.67 23    UMa
                    fcb       -67,-102,34   * V 3.67 28Bet Ser
                    fcb       -70,80,-70    * V 3.68 Alp Pyx
                    fcb       -125,-23,-3   * V 3.68 29Gam Vir
                    fcb       -68,-87,62    * V 3.68 3Bet CrB
                    fcb       100,-70,-36   * V 3.68 40Gam Cap
                    fcb       76,90,-47     * V 3.69 16Tau4Eri
                    fcb       37,121,12     * V 3.69 3Pi 4Ori
                    fcb       125,-24,7     * V 3.69 6Gam Psc
                    fcb       64,96,52      * V 3.70 17    Tau
                    fcb       -1,-111,62    * V 3.70 92Xi  Her
                    fcb       2,123,-31     * V 3.71 16Eta Lep
                    fcb       -85,5,94      * V 3.71 63Chi UMa
                    fcb       -68,-107,10   * V 3.71 37Eps Ser
                    fcb       61,-111,14    * V 3.71 60Bet Aql
                    fcb       36,122,5      * V 3.72 8Pi 5Ori
                    fcb       0,74,103      * V 3.72 33Del Aur
                    fcb       -95,-84,4     * V 3.72 109    Vir
                    fcb       66,-63,88     * V 3.72 62Xi  Cyg
                    fcb       75,-66,78     * V 3.72 65Tau Cyg
                    fcb       110,58,-23    * V 3.73 55Zet Cet
                    fcb       75,100,-21    * V 3.73 18Eps Eri
                    fcb       -45,85,-83    * V 3.73 
                    fcb       4,-125,21     * V 3.73 72    Oph
                    fcb       77,98,21      * V 3.74 2Xi  Tau
                    fcb       92,-73,-48    * V 3.74 34Zet Cap
                    fcb       120,-36,-17   * V 3.74 73Lam Aqr
                    fcb       24,93,83      * V 3.75 8Zet Aur
                    fcb       -62,60,-93    * V 3.75 
                    fcb       -50,-109,42   * V 3.75 20Gam Her
                    fcb       -7,-127,6     * V 3.75 62Gam Oph
                    fcb       -2,-69,106    * V 3.75 32Xi  Dra
                    fcb       61,-26,108    * V 3.75 27Del Cep
                    fcb       52,48,105     * V 3.76 15Eta Per
                    fcb       50,110,38     * V 3.76 61Del1Tau
                    fcb       101,-54,54    * V 3.76 24Iot Peg
                    fcb       52,78,86      * V 3.77 41Nu  Per
                    fcb       33,-113,-47   * V 3.77 39Omi Sgr
                    fcb       25,-72,102    * V 3.77 1Kap Cyg
                    fcb       78,-94,35     * V 3.77 9Alp Del
                    fcb       84,-93,-21    * V 3.77 2Eps Aqr
                    fcb       75,-31,98     * V 3.77 7Alp Lac
                    fcb       -33,114,45    * V 3.79 43Zet Gem
                    fcb       -41,105,59    * V 3.79 60Iot Gem
                    fcb       30,-73,100    * V 3.79 10Iot2Cyg
                    fcb       48,-73,92     * V 3.79 31    Cyg
                    fcb       61,66,90      * V 3.80 27Kap Per
                    fcb       -55,35,109    * V 3.80 29Ups UMa
                    fcb       -108,50,43    * V 3.80 41Gam2Leo
                    fcb       -74,-101,23   * V 3.80 13Del Ser
                    fcb       -74,-101,23   * V 3.80 13Del Ser
                    fcb       -8,-88,91     * V 3.80 85Iot Her
                    fcb       12,126,-6     * V 3.81 48Sig Ori
                    fcb       4,119,-45     * V 3.81 15Del Lep
                    fcb       -111,48,-37   * V 3.81 42Mu  Hya
                    fcb       39,102,-65    * V 3.82 52Ups2Eri
                    fcb       -78,66,76     * V 3.82 38    Lyn
                    fcb       -48,-117,4    * V 3.82 10Lam Oph
                    fcb       54,-107,40    * V 3.82 7Del Sge
                    fcb       87,-9,92      * V 3.82 16Lam And
                    fcb       60,89,68      * V 3.83 38Omi Per
                    fcb       -101,30,71    * V 3.83 46    LMi
                    fcb       -82,-46,-85   * V 3.83 Phi Cen
                    fcb       4,-111,61     * V 3.83 103Omi Her
                    fcb       19,-38,120    * V 3.83 63Eps Dra
                    fcb       47,113,35     * V 3.84 77The1Tau
                    fcb       -56,67,-92    * V 3.84 
                    fcb       -44,6,119     * V 3.84 1Lam Dra
                    fcb       -64,-94,56    * V 3.84 8Gam CrB
                    fcb       12,-117,47    * V 3.84 109    Her
                    fcb       115,-53,-3    * V 3.84 48Gam Aqr
                    fcb       -10,105,-70   * V 3.85 Del Col
                    fcb       -36,107,-57   * V 3.85 28Ome CMa
                    fcb       -84,42,-85    * V 3.85 
                    fcb       -116,47,21    * V 3.85 47Rho Leo
                    fcb       -63,-105,34   * V 3.85 41Gam Ser
                    fcb       19,-124,-18   * V 3.85 Alp Sct
                    fcb       42,84,-85     * V 3.86 Alp Hor
                    fcb       -2,-101,77    * V 3.86 91The Her
                    fcb       7,-118,-46    * V 3.86 13Mu  Sgr
                    fcb       96,24,79      * V 3.87 37Mu  And
                    fcb       74,83,-62     * V 3.87 Alp For
                    fcb       64,96,52      * V 3.87 20    Tau
                    fcb       43,115,-31    * V 3.87 53    Eri
                    fcb       13,103,-74    * V 3.87 Eps Col
                    fcb       -27,113,-52   * V 3.87 16Omi1CMa
                    fcb       -43,-6,119    * V 3.87 5Kap Dra
                    fcb       -78,-45,-89   * V 3.87 Ups1Cen
                    fcb       89,4,-91      * V 3.88 Eps Phe
                    fcb       -95,84,5      * V 3.88 22The Hya
                    fcb       -97,60,56     * V 3.88 24Mu  Leo
                    fcb       -90,-38,-81   * V 3.88 
                    fcb       -96,-83,-13   * V 3.88 107Mu  Vir
                    fcb       -57,-95,-62   * V 3.88 5Rho Sco
                    fcb       90,87,-20     * V 3.89 3Eta Eri
                    fcb       -127,-11,-1   * V 3.89 15Eta Vir
                    fcb       -37,-79,92    * V 3.89 22Tau Her
                    fcb       51,-91,73     * V 3.89 21Eta Cyg
                    fcb       -75,102,-9    * V 3.90 
                    fcb       60,-112,2     * V 3.90 55Eta Aql
                    fcb       87,-19,-90    * V 3.90 Iot Gru
                    fcb       62,110,13     * V 3.91 38Nu  Tau
                    fcb       -58,66,-91    * V 3.91 
                    fcb       -104,73,-3    * V 3.91 35Iot Hya
                    fcb       -72,-99,-32   * V 3.91 38Gam Lib
                    fcb       -28,-105,65   * V 3.92 58Eps Her
                    fcb       95,-83,12     * V 3.92 8Alp Equ
                    fcb       45,118,-7     * V 3.93 48Nu  Eri
                    fcb       -54,113,-21   * V 3.93 26Alp Mon
                    fcb       42,-113,-39   * V 3.93 44Rho1Sgr
                    fcb       91,10,-88     * V 3.94 Kap Phe
                    fcb       -79,91,40     * V 3.94 47Del Cnc
                    fcb       -123,20,23    * V 3.94 78Iot Leo
                    fcb       67,-68,84     * V 3.94 58Nu  Cyg
                    fcb       56,53,101     * V 3.95 18Tau Per
                    fcb       -19,118,-42   * V 3.95 7Nu 2CMa
                    fcb       -68,-26,104   * V 3.95 79Zet UMa
                    fcb       -56,-89,-70   * V 3.95 5Chi Lup
                    fcb       110,-37,51    * V 3.95 47Lam Peg
                    fcb       43,96,-71     * V 3.96 43    Eri
                    fcb       0,93,-86      * V 3.96 Eta Col
                    fcb       -23,105,-68   * V 3.96 13Kap CMa
                    fcb       -49,100,-61   * V 3.96 3    Pup
                    fcb       -56,-105,-45  * V 3.96 9Ome1Sco
                    fcb       4,98,80       * V 3.97 32Nu  Aur
                    fcb       -67,79,-73    * V 3.97 Bet Pyx
                    fcb       -67,67,85     * V 3.97 
                    fcb       0,-127,6      * V 3.97 67    Oph
                    fcb       35,-90,-83    * V 3.97 Alp Sgr
                    fcb       85,-36,-87    * V 3.97 Del1Gru
                    fcb       118,-19,-44   * V 3.97 98    Aqr
                    fcb       33,20,121     * V 3.98 50    Cas
                    fcb       -8,126,-14    * V 3.98 5Gam Mon
                    fcb       48,-71,94     * V 3.98 32    Cyg
