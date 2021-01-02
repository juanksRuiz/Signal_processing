function centeredBBOX = CenteredForeheadBBOX(BBOX_face, BBOX_eyes)
%[x y w h]
frente = FullForeheadBBOX(BBOX_face, BBOX_eyes);
newX = frente(1) + 0.25*frente(3);
newY = frente(2) + 0.25*frente(4);
newW = 0.5*frente(3);
newH = 0.5*frente(4);

centeredBBOX = [newX, newY, newW, newH];
end