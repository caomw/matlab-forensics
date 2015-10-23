test_size = [1024, 1024];
tamp_size = [256, 256];
c1Y = 1;
c2Y = 15;
c2Yb = 15;
JPEGqualities = 50:5:100;
if ispc
    origfoldername='JPEGDQ';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGDQ';
else
    origfoldername='/images/Prove/Bianchi/JPEGDQ';
end
% number of points on ROC
N = 100;
% number of false positives and true positives in each test
% FPmat = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat = zeros(length(JPEGqualities),length(JPEGqualities),N);
% FPmat_old = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat_old = zeros(length(JPEGqualities),length(JPEGqualities),N);
% number of positives (tampered pixels)
PN = prod(tamp_size);
% number of negatives (original pixels)
NN = prod(test_size) - PN;
Nfiles = 0;
PNtot = 0;
NNtot = 0;

Nvalid = 0;
Ntrue = 0;
Nna = 0;
Nnd = 0;
NQvalid = zeros(8);
NQtrue = zeros(8);
NQna = zeros(8);
NQnd = zeros(8);
alphatrueDC = [];
alphatrueAC = [];
msetrueDC = [];
msetrueAC = [];
nztrueDC = [];
nztrueAC = [];
alphafalseDC = [];
alphafalseAC = [];
msefalseDC = [];
msefalseAC = [];
nzfalseDC = [];
nzfalseAC = [];
alphanaDC = [];
alphanaAC = [];
msenaDC = [];
msenaAC = [];
nznaDC = [];
nznaAC = [];
alphandDC = [];
alphandAC = [];
msendDC = [];
msendAC = [];
nzndDC = [];
nzndAC = [];

directory = dir([origfoldername, '/*.tif']);
files = {directory.name};
for i=1:length(files)
    if ~directory(i).isdir
        Nfiles = Nfiles + 1;
        current_file = char(files(i));
        filename = [origfoldername, '/', current_file];
               
        I = imread(filename);
        [h,w,dummy] = size(I);
        % cut center part (test_size)
        p1 = floor(([h w] - test_size)/2) + 1;
        p2 = p1 + test_size - 1;
        Itest = I(p1(1):p2(1),p1(2):p2(2),:);
        % define mask for tampering (tamp_size)
        mask = false(size(Itest));
        pt1 = floor((test_size - tamp_size)/2) + 1;
        pt2 = pt1 + tamp_size - 1;
        mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'same');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        for k1 = 1:length(JPEGqualities)
            qf1 = JPEGqualities(k1);
            jpg_filename = [filename(1:end-4), '_Q', num2str(qf1), '.jpg'];
            imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
            image = jpeg_read(jpg_filename);
            q1ref = image.quant_tables{1};
            I2 = imread(jpg_filename);
            % insert tampering
            I2(mask) = Itest(mask);
            
            for k2 = 1:length(JPEGqualities)
                qf2 = JPEGqualities(k2);
                jpg_t_filename = [jpg_filename(1:end-4), '_Q', num2str(qf2), '.jpg'];
                imwrite(I2, jpg_t_filename, 'jpg', 'Quality', qf2);
                image = jpeg_read(jpg_t_filename); 
                q2ref = image.quant_tables{1};
                
                [maskTampered, q1table, alphatable, msetable, nztable] = getJmap_stat(image, 1, c1Y, c2Y);
                
                qvalid = q1table < 100;
                dc = false(size(qvalid));
                dc(1,1) = true;
                ac = not(dc);
                qna = qvalid & (mod(q2ref,q1table) == 0) & (mod(q2ref,q1ref) == 0);
                qnd = qvalid & (mod(q2ref,q1table) == 0) & not(qna);
                qamb = qvalid & (q1ref == q2ref.*q1table) & (mod(q2ref,q1table) == 1)...
                    & (mod((q2ref-1)./q1table,2) == 0);
                qtrue = qvalid & ((q1table == q1ref) | qamb) & not(qna); 
                qfalse = qvalid & not(qtrue) & not(qna) & not(qnd);
                
                qstrange = (alphatable > 0.9) & qfalse;
                if sum(qstrange(:)) > 0
                    q2ref(qstrange)
                    q1ref(qstrange)
                    q1table(qstrange)
                    alphatable(qstrange)
                    nztable(qstrange)
                    pause
                end
                
                Nvalid = Nvalid + sum(qvalid);
                Ntrue = Ntrue + sum(qtrue);
                Nna = Nna + sum(qna);
                Nnd = Nnd + sum(qnd);
                
                NQvalid = NQvalid + qvalid;
                NQtrue = NQtrue + qtrue;
                NQna = NQna + qna;
                NQnd = NQnd + qnd;
                
                alphatrueDC = [alphatrueDC; alphatable(qtrue & dc)];
                alphatrueAC = [alphatrueAC; alphatable(qtrue & ac)];
                alphafalseDC = [alphafalseDC; alphatable(qfalse & dc)];
                alphafalseAC = [alphafalseAC; alphatable(qfalse & ac)];
                msetrueDC = [msetrueDC; msetable(qtrue & dc)];
                msetrueAC = [msetrueAC; msetable(qtrue & ac)];
                msefalseDC = [msefalseDC; msetable(qfalse & dc)];
                msefalseAC = [msefalseAC; msetable(qfalse & ac)];
                nztrueDC = [nztrueDC; nztable(qtrue & dc)];
                nztrueAC = [nztrueAC; nztable(qtrue & ac)];
                nzfalseDC = [nzfalseDC; nztable(qfalse & dc)];
                nzfalseAC = [nzfalseAC; nztable(qfalse & ac)];
                alphanaDC = [alphanaDC; alphatable(qna & dc)];
                alphanaAC = [alphanaAC; alphatable(qna & ac)];
                msenaDC = [msenaDC; msetable(qna & dc)];
                msenaAC = [msenaAC; msetable(qna & ac)];
                nznaDC = [nznaDC; nztable(qna & dc)];
                nznaAC = [nznaAC; nztable(qna & ac)];
                alphandDC = [alphandDC; alphatable(qnd & dc)];
                alphandAC = [alphandAC; alphatable(qnd & ac)];
                msendDC = [msendDC; msetable(qnd & dc)];
                msendAC = [msendAC; msetable(qnd & ac)];
                nzndDC = [nzndDC; nztable(qnd & dc)];
                nzndAC = [nzndAC; nztable(qnd & ac)];
            end
        end
    end
end

Ftrue = Ntrue / Nvalid;
FQtrue = NQtrue ./ NQvalid;
Fna = Nna / Nvalid;
FQna = NQna ./ NQvalid;
Fnd = Nnd / Nvalid;
FQnd = NQnd ./ NQvalid;

% FPmat = FPmat / NNtot;
% TPmat = TPmat / PNtot;
% FPmat_old = FPmat_old / NNtot;
% TPmat_old = TPmat_old / PNtot;
% 
% AUC = zeros(length(JPEGqualities));
% AUC_old = zeros(length(JPEGqualities));
% for k1 = 1:length(JPEGqualities)
%     for k2 = 1:length(JPEGqualities)
%         AUC(k1,k2) = trapz(squeeze(FPmat(k1,k2,:)), squeeze(TPmat(k1,k2,:)));
%         AUC_old(k1,k2) = trapz(squeeze(FPmat_old(k1,k2,:)), squeeze(TPmat_old(k1,k2,:)));
%     end
% end

save testDQstat_out Ftrue FQtrue Fna FQna Fnd FQnd...
    alphatrueDC alphatrueAC alphafalseDC alphafalseAC alphanaDC alphanaAC alphandDC alphandAC...
    msetrueDC msetrueAC msefalseDC msefalseAC msenaDC msenaAC msendDC msendAC...
    nztrueDC nztrueAC nzfalseDC nzfalseAC nznaDC nznaAC nzndDC nzndAC
% AUC
% AUC_old
