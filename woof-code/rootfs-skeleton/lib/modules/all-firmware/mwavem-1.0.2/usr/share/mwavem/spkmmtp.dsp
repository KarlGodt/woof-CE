RIFF=  MSP isp �    ObMICROCODE SOURCE MATERIALS.  MWAVE MICROCODE.  (C) COPYRIGHT IBM CORP. 1996.  ALL RIGHTS RESERVED.�US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH IBM CORP. 12/19/96o��2toc �   tsk 8    SPKVOD�  M896"  M968�  MOVELINE"  MOVEMIC�  iseg<    spkvodC0  m896is�  m968is:#  movesc�)  movesc.1�*  dseg<    PDSEGD,  PDSEG.1p7  PDSEG.2�8  PDSEG.3�:  PDSEG.4�;  mod �  mhdr
    SPKMMTPtins    SPKVODSPKVOD tins    M896M896 tins    M968M968 tins    MOVELINEMOVELINE tins    MOVEMICMOVEMIC gpcc,    BIOS  VOICE96_OUTPUT  M968 
M968_INPUT  gpcc,     M968 M968_OUTPUT  MOVEMIC 
MOVE_INPUT  gpcc*     MOVEMIC MOVE_OUTPUT  SPKVOD MICIN   gpcc.     SPKVOD 
SPEAKEROUT  MOVELINE 
MOVE_INPUT  gpcc.     MOVELINE MOVE_OUTPUT  M896 
M896_INPUT   gpcc,     M896 M896_OUTPUT BIOS  VOICE96_INPUT  taskz   thdr   SPKVODAIC1    �  �%  H stnd   spkvodCSTANDBYactv   spkvodCMAIN aluo     dds    PDSEGcs     spkvodCtaskx   thdr   M896 AIC1    h  �%   stnd   m896isSTANDBY actv   m896isMAINaluo     dds    PDSEG.1cs     m896is taskx   thdr   M968 AIC1    ^  �%   stnd   m968isSTANDBY actv   m968isMAINaluo     dds    PDSEG.2cs     m968is task|   thdr   MOVELINE AIC1    �   �%   stnd   movescSTANDBY actv   movescMAINaluo     dds    PDSEG.3cs     movesc task�   thdr   MOVEMIC AIC1    �   �%    stnd   movesc.1STANDBY actv   movesc.1MAINaluo     dds    PDSEG.4cs  
   movesc.1 code�  shdr   spkvodC       �  nstr   MAIN STANDBY  dstrF     �� spkvodC SYSTMP4 SYSTMP0 SYSTMP1 SYSTMP2 SYSDSPTR SYSRTN  xtrn�          3                      2                      *                     ! �                      �                     * �                     ! �                      �                     3 �                     * �                     ! �                      �                     = �                      3 �                     3 �                      9                      2                      �                      ! �                       �                      * �                      * �                      ! �                       �                      * �                      3 �                      3 �                      ! �                       �                      = 0                       3 ,                      3                       3                pubs     2            imag8      �  À$ �(    x � � p �( �9 x � �8 �( �( <��  ? �� B� ��D   ; � p     0 p �8 �9 ��$ � ) � * �( �(  =  : �� � p      � �8 �9 À$ �( �(  ?  ?  ;  ; �� � p      � �8  �$   d �9  �$ �( �� �D � )   - L� @u �Hq � �,q  )v �  u � 9 �( ��p �D � )   - � 9 �( ��p �D � )   - � 9 �$ �( Pd   �$ �( 0 p X}  >  � �8 �_} ��. xIw ��} * ��v  X}  . xIw ��v : ��} �( @ � �    [d   �$ �( 0 p  � �8 �$ �( .d   �$ �( 0 p X}  >  � �8 u l�/ o�. &�s ��r (�u ��r ��r Q} * �Xv   /  . &�s ��r (�u ��r ��r ��v : �} �( � l � %  0d   �$ �( 0 p  � �8  �$ (	   1 � @   0   Ad       0 p � �d    �� P}  : "�   ��- |� �Wq �Br !� ��D P}     0 p @ d   : Q} ��v �d   	9   0 (  0    3  �}  . ��r 0D ��p �d   �t 	* ��r    9  �}  .    0 �d   
)    �+q   = -�  # ��q �D  0 ( ��     �  . ��r  D �$q ��q �@r !� ��D  .    ��q �  ��   0 p ��-   = �b� ��D ��-   > � ) � 9 � ) � 9 � ; �  �� �d�   . �Kq �D     �"s ��D   . ; �as ��D � ) � * �H� ��q Cw �Ar ��D � ) �!q �D �'q   �)q ��D   �)q ��D � ) �$ �( �  �er � � H)t �lp ��q ��r ��s �� �Tt �}  . ��v �D  � �Rv ��q  0 �"s ��D �}   �(q  9    yIw ��} ��. i�w �Rv �}  . i�w �Rv P}  : ��} � * �Xv Z�D �( �  �er � � H)t �lp ��q ��r ��s 0 p X}  .  �}  . �Xv �D 0 p �Rv �}  . �Xv �D 0 p �Rv P}  : ��v d    9 �}  * d    9 �$ �( � )  + �"s � �   ��r ��p )t ��q ��r ��q 0 p  .  ��  ��q I�w � ) )w ��q  �D 0 p �d   �t  *  ) �(r �(q  9  + � �br ��r   w "w �Kq  ) <�r �4q  9 � ) �%q )v " * $H� <�r �4q " 9 )w �%q   9 �$ �( 0 p  . ' :  . ) : �(   )  . + :  . - : H)t �  �er �lp ��q ��r ��s 0 p  �}  . �_} ��. ��v �D 0 p ��v /�} 1 : �$ �(   ) )t   ��q ��p ��q ��q ��r 0 p  . ��- �u 3 :  �$ &�} ) * �P} � * ��v �D 0 p �Rv �P} � : *�} - * �P} � * ��v �D 0 p �Rv �P} � : � ) �$q � ) �(q �D � 9 ��} � * �P} � * ��v �D 0 p �Rv �P} � : ��} � * �P} � * ��v �D 0 p �Rv �P} � : �$p � 9 � 9 � 9 � 9 � 9 � ) �!q 	�D �P} � * �P} � : �P} � * �P} � : � ) �$q � ) �(q :�D � 9 � ) �P} � * �P} � : ��} � * ��v  D �pv &�s ��r (�u ��r ��r �Rv ��} � * ��v �Xv �D 0 p �Rv �P} � : �P} � * �P} � : ��} � * ��v  D �pv &�s ��r (�u ��r ��r �Rv ��} � * ��v �Xv �D 0 p �Rv �P} � : ��� � ; � ; � ; � : � ; � : *�} - * y�w �P} � * ��v �D ��} � * ��v �D 0 p �Rv ��v �Sv �Sv � * @v ��} � * �Xv �D 0 p �Rv �P} � : &�} ) * y�w �P} � * ��v �D ��} � * ��v �D 0 p �Rv ��v �Sv �Sv � * @v ��} � * �Xv �D 0 p �Rv �P} � :  �$ ) * &�} �d   5 9 1 * .�} �d   7 9 3 * �d   �t 9 9 &P} ( * ��} � * �Xv �D    4 ) 6 * 8(� 
(� (� �+q �D      *P} , * ��} � * �Xv �D   ��r = ;  )  * �(r 
 * �(r Y)w     v �d   � )  u  9 : ) < * �)r %�D   �)r "�D 0 p &�} ) * �P} � * y�w ��v pD � ) ��v 8�t �Xv �pv &�s �Tr (Ju �Br �Br ��v ��} � : �d   � + ��q Y�w � )  �u    w �d   � 9 : ) = + H)t �/s L  )t ��q 0 p  d�  A ��r > ; D ; B ; @ ; 6 d ; + D ; B ; @ ; l  ��q > *  H� >�� ,�D ; + = + ) d ; ; > ; B ; @ ; l  ��q D *  H� D�� �D ; + = +  d ; ; > ; D ; @ ; l  ��q B *  H� B�� �D ; + = +  d ; ; > ; D ; B ; l  ��q @ *  H� @�� �D ; + = +  d ; ; �  �t ��s 0 p  /  A 0 p F + � ;  )  d � 9 J + � ;  )  d � 9 H + � ; � ) 	 d � 9 H + � ; � ) Y�w �   �u � 9 H + � ; � ) � 9 �$ �( � + ��- �(� ��  ��   �)r �D �ts �  �lq   ? � ; � * d   � + �� 
 + �Bs YIw ��r    w d   ��q �( � + ��- �(�  �� �ts   �)q �D `v � +   ? � ; À$ � )    �w �( �( <��  . <�r ��r ��v ��v ��v  : "� ��D �� � p     0 p �9 �8 � )    �w �( �( <��  . <�r ��r ��v ��v ��v ��v  : "� ��D �� � p     0 p �9 �8  �$   d 0 p �� �Tt  - �w � �w V� �w V� �w 
V� �w V� �w V� �w V� �w V� �w V� �w V� �w V� �w V� �w V� �w "� �D 0 p ��s  A �Sv   0   1  3  �� X}  . �Xv A� D P} �Xv  �v bu "� ��D       �� �(s      #  X}  .  Iu b� ��D ��>  # ��s  A 0 p  3 ��q     �Tt ��t  -   ) � ֙ V� ֙ V� ֙ V� ֙ V� ֙ V� ֙ V� ֙  V�  ֙ $V� $֙ (V� (֙ ,V� ,֙ 0V� 0֙ 4V� 4֙ 8V� 8֙ <V� <֙ @V� @֙ DV� D֙ HV� H֙ LV� L֙ PV� P֙ TV� T֙ XV� X֙ \V� \֙ `V� `֙ dV� d֙ hV� h֙ lV� l֙ pV� p֙ tV� t֙ xV� x֙ |V� |֙ �V� �֙ �Br     -� �}  : P}  : � �D   0  # ��s  A 0 p �Tt  - � V� V� V� V� V� V�  V� $V� (V� ,V� 0V� 4V� 8V� <V� @V� DV� HV� LV� PV� TV� XV� \V� `V� dV� hV� lV� pV� tV� xV� |V� �Vq ��s  A �Br T   $v h�  �w ��� �t ��r �"r  - )v ��s  A ��q T �� �D   ��v    $v h�  �w ��q �t ��r �"r  - )v ��s  A ��q `� �  Y)u �$q  �u Xiw �lr � it ��s 0 p   - <�q ��s  A ��q codez  shdr   m896is        C   nstr   STANDBY MAIN  dstr      �� m896is SYSRTN SYSDSPTR xtrn�           A                       ;                                            �                       �                       q                       ?                       	                pubs           	      imag      C  Â$ �d� �� B� �D   ? � � � 9 ( �   ` � 8 Â$ � (    -   ) � Й P� � ԙ T� � $ԙ T� � 0ԙ 
T� � <ԙ T� � Hԙ T� � Tԙ T� � `ԙ T� � lԙ T� � xԙ T�  � �ԙ T� "� �ԙ T� $� �ԙ T� &� �ԙ T� (� �Ԙ T�  :  :      -  ) � Й P� � ԙ T� � &ԙ T� � 2ԙ 
T� � >ԙ T� � Jԙ T� � Vԙ T� � bԙ T� � nԙ T� � zԙ T�  � �ԙ T� "� �ԙ T� $� �ԙ T� &� �ԙ T� (� �Ԙ T�  :  :      -  ) � Й P� � ԙ T� � (ԙ T� � 4ԙ 
T� � @ԙ T� � Lԙ T� � Xԙ T� � dԙ T� � pԙ T� � |ԙ T�  � �ԙ T� "� �ԙ T� $� �ԙ T� &� �ԙ T� (� �Ԙ T�  :  :      -  ) � Й P� � ԙ T� � *ԙ T� � 6ԙ 
T� � Bԙ T� � Nԙ T� � Zԙ T� � fԙ T� � rԙ T� � ~ԙ T�  � �ԙ T� "� �ԙ T� $� �ԙ T� &� �ԙ T� (� �Ԙ T� 	 :  :      -  ) � Й P� �  ԙ T� � ,ԙ T� � 8ԙ 
T� � Dԙ T� � Pԙ T� � \ԙ T� � hԙ T� � tԙ T� � �ԙ T�  � �ԙ T� "� �ԙ T� $� �ԙ T� &� �ԙ T� (� �Ԙ T�  :  :      - 
 ) � Й P� � "ԙ T� � .ԙ T� � :ԙ 
T� � Fԙ T� � Rԙ T� � ^ԙ T� � jԙ T� � vԙ T� � �ԙ T�  � �ԙ T� "� �ԙ T� $� �ԙ T� &� �ԙ T� (� �Ԙ 
T�  : M� �� ��p     ��r �D � 9 ��d  -   ` � 8 codeJ  shdr   m968is        >   nstr   STANDBY MAIN  dstr      �� m968is SYSRTN SYSDSPTR xtrn�           <                       6                      �                       �                       �                       H                       	                pubs           	      imag       >  Â$ �d� �� B� �D   ? � � � 9 0 �   ` � 8 Â$ � (    -  ) � Й P� � ԙ T� � &ԙ T� � 0ԙ 
T� � :ԙ T� � Dԙ T� � Nԙ T� � Xԙ T� � bԙ T�  � lԙ T� "� vԙ T� $� �ԙ T� &� �ԙ T� (� �ԙ T� *� �ԙ  T� ,� �ԙ "T� .� �ԙ $T� 0� �Ԙ T�  :  :      -  ) � Й P� � ԙ T� � $ԙ T� � .ԙ 
T� � 8ԙ T� � Bԙ T� � Lԙ T� � Vԙ T� � `ԙ T�  � jԙ T� "� tԙ T� $� ~ԙ T� &� �ԙ T� (� �ԙ T� *� �ԙ  T� ,� �ԙ "T� .� �ԙ $T� 0� �Ԙ T�  :  :      -  ) � Й P� � ԙ T� � "ԙ T� � ,ԙ 
T� � 6ԙ T� � @ԙ T� � Jԙ T� � Tԙ T� � ^ԙ T�  � hԙ T� "� rԙ T� $� |ԙ T� &� �ԙ T� (� �ԙ T� *� �ԙ  T� ,� �ԙ "T� .� �ԙ $T� 0� �Ԙ T�  :  :      -  ) � Й P� � ԙ T� �  ԙ T� � *ԙ 
T� � 4ԙ T� � >ԙ T� � Hԙ T� � Rԙ T� � \ԙ T�  � fԙ T� "� pԙ T� $� zԙ T� &� �ԙ T� (� �ԙ T� *� �ԙ  T� ,� �ԙ "T� .� �ԙ $T� 0� �Ԙ T� 	 :  :      -   ) � 
Й P� � ԙ T� � ԙ T� � (ԙ 
T� � 2ԙ T� � <ԙ T� � Fԙ T� � Pԙ T� � Zԙ T�  � dԙ T� "� nԙ T� $� xԙ T� &� �ԙ T� (� �ԙ T� *� �ԙ  T� ,� �ԙ "T� .� �ԙ $T� 0� �Ԙ T�  : M� �� ��p     ��r �D � 9 ��d  -   ` � 8 codeR  shdr   movesc       #    nstr   MAIN STANDBY  dstr      �� movesc SYSRTN SYSDSPTR xtrn8           !                                       pubs                  imag�       #    (  *   . H� YIw L� �Is �D 0 p  (  )   . H� H� YIw L� �Is �D 0 p À$  -�  (    / B� A� ��D �� � p     0 p  8  9   d 0 p codeV  shdr   movesc.1       #    nstr   MAIN STANDBY  dstr"     �� movesc.1 SYSRTN SYSDSPTR xtrn8           !                                       pubs                  imag�       #    (  *   . H� YIw L� �Is �D 0 p  (  )   . H� H� YIw L� �Is �D 0 p À$  -�  (    / B� A� ��D �� � p     0 p  8  9   d 0 p data$  shdr   PDSEG       e  nstr  SILENTINDITCB SPKPITCB GAINSPK LINEGAIN MICGAIN ELINE EMIC 
SPEAKEROUT LINEOUT LINEIN MICIN 
_SilentInd _Mute _GainSpk 
LineGainsp 	MicGainsp ELinep EMicp SinkSp SinkLp SourceLp SourceMp GoodCorr HisPos HisCor CorTh 	SilentInd ELineTh EMicTh SilShortIndx SilShort MaxSilTh ltEMic MicGain LGMinMic 
LogAGCGoal LineGain 
CurMicGain CurLineGain LogLoopGain Mute 
GainSpkDef TmpState 	PrevState ELine EMic ltADelay ADelay 
MicLowGain LogAa2 LogGa2 ltLogGe2 ltLogGa2 LogEchoLevelGoal2 Mode dstr�     �� PDSEG set_for_both spkvodC set_for_mic set_for_line set_for_silent no_change_in_state to_mic to_line 	to_silent to_both xtrn0           �    �  ;                �    �  6                �    �  1                �    �  ,                j    �  �                h    �                  f    �  �                d    �  �                b    �                  `    �  �                ^    �  �                \    �  �                Z    �                  X    �                  V    �  �                T    �  �                R    �                  P    �                  N    �  �                L    �  �       pubs`  f �    r �    y �    � �    � �    � �    � �    � �    � �    � �    � �    �     � �     � �     � �     � �     � �     �     
�     �     "�     ,�     4�     =�     G�     S�     ]�     i�     v�     ��     ��     �<     �:     �*     �&     �"     �      �     �
     �     �     �     �           gpc *   "   @   �     �                     gpc *   ,   @   �     �                     gpc *   5   �   �     �                     gpc *   <   �   �     �                     gpc *   B   �   �     @  < <                 gpc *   N   �   �     @  < <                 gpc *   W  �   �     @  < <                 gpc *   _  �   �     @  < <                 itcb         �          itcb        �          itcb        �          imag�      e     � �    W                �y�� �y            �                   �~3s @                                                            @ 3s3s �� � � � �  4 ��  0                                    
           3s   � � � �                                               ������������������������                                                                                                                                                                                                                                                                                       - B W k  � � � � � � � ,;JXgu���������� @�B�E�HL{O�R�V�Z�^�bg�kfp`u�z����������������      data�  shdr   PDSEG.1       \   nstr   M896_OUTPUT 
M896_INPUT  dstr     �� PDSEG.1  gpc *       �   �      �%  0                  gpc *     �   �      @  (    �j             imag�       \     ����������q�a�l�����b � ?nL� ������-�������� ����81 ���/�j�o���� ��&20;@@0;2&��� ��o�j�/��� �18����� ������-�������� Ln?� b ����l�a�q�����������  ����data�  shdr   PDSEG.2       \   nstr   M968_OUTPUT 
M968_INPUT  dstr     �� PDSEG.2  gpc *       �   �      @  (    �j             gpc *     �   �      �%  0                  imag�       \    G a � � � � 9 ��^������r�+ � ��4����6�q�������'�
!w"��1�����N���`� �,6M;M;6�, �`��N�����1���"w!
�'������q�6�����4��� + r������^���9 � � � � a G  ����dataF  shdr   PDSEG.3          nstr,   MOVE_OUTPUT 
MOVE_INPUT sinkpp sourcegp  dstr     �� PDSEG.3  xtrn8                �                       �           pubs         !       gpc *       �         @                     gpc *     �          @                     imag          ��    ��    dataF  shdr   PDSEG.4          nstr,   MOVE_OUTPUT 
MOVE_INPUT sinkpp sourcegp  dstr     �� PDSEG.4  xtrn8                �                       �           pubs         !       gpc *       �         @                     gpc *     �          @                     imag          ��    ��    