
# une classe 2d (x,y)qui divise une ellipse en n points donnés et renvoie un tableau d'edges de longueurs identiques le long d'une ellipse.
# le premier point étant aux coordonnées (grand rayon, 0.0)
class Ellipse
  attr_reader :edges 

  def initialize(centre, grand_rayon, petit_rayon, nb_points, model)
    @centre = centre
    @grand_rayon = grand_rayon.to_f
    @petit_rayon = petit_rayon.to_f
    @nb_points = nb_points.to_i
    @nb_points = 5 if @nb_points < 5
    @model = model
    @edges = dessiner_ellipse
  end

  def dessiner_ellipse
    pts_tab = Array.new
    cond = true
    precis_l = 1.cm


    # on prend une longueur de segment à peu près bonne
    l = (2 * Math::PI * (@grand_rayon + @petit_rayon) / 2.0) / @nb_points
   
    while cond
      pts_tab.clear
      pts_tab << Geom::Point3d.new(@grand_rayon, 0.0, 0.0)

      #on part d'un premier point aux coordonnées grand_rayon, 0
      a = 1.0 - @petit_rayon**2 / @grand_rayon**2
      b = - 2.0 * @grand_rayon
      c = @grand_rayon**2 + @petit_rayon**2 - l**2
      delta = b**2 - 4.0 * a * c
      x1 = (- b + Math.sqrt(delta)) / (2.0 * a)
      e = @petit_rayon**2 * (1.0 - x1**2/(@grand_rayon**2))
      if e < 0.0
        x1 = (- b - Math.sqrt(delta)) / (2.0 * a)
        e = @petit_rayon**2 * (1.0 - x1**2/(@grand_rayon**2))
      end
      y1 = Math.sqrt( e)
      pts_tab << Geom::Point3d.new(x1, y1, 0.0)
      angle_dep = Math.atan(y1 / x1)
      angle = angle_dep

      # on cherche tous les autres points sur une demi ellipse en faisant varier l'angle
      for i in 1..(@nb_points/2.0).floor - 1
        dis = 0.0
        x2 = 0.0
        until (dis-l).abs < precis_l && (x2-x1).abs > 5.0
          angle += angle_dep*(l - dis)/(l*2.0) #angle_dep/(l / (precis_l*10.0))
          x2 = @grand_rayon * Math.cos(angle)
          y2 = @petit_rayon * Math.sin(angle)
          dis = Math.sqrt((x2-x1)**2 + (y2-y1)**2)
        end
        x1 = x2
        y1 = y2
        pts_tab << Geom::Point3d.new(x1, y1, 0.0)
      end

      #on vérifie qu'on arrive à peu près où il faut, si oui on arrête, si non, on ajuste la longueur l et on recommence
      if @nb_points % 2 == 0
        if y2.abs < precis_l
          cond = false
        else
          l += (y2/(@nb_points*20.0))#0.01
        end
      else
        if (y2-l/2.0).abs < precis_l
          cond = false
        else
          l += (y2-l/2.0)/(@nb_points*20.0)
        end
      end

    end

    # on rajoute les points de la demi-ellipse inférieure
    if @nb_points % 2 == 0
      for i in (@nb_points/2 - 1).downto(1)
        pts_tab << Geom::Point3d.new(pts_tab[i].x , -pts_tab[i].y, 0.0)
      end
    else
      for i in ((@nb_points-1)/2).to_i.downto(1)
        pts_tab << Geom::Point3d.new(pts_tab[i].x , -pts_tab[i].y, 0.0)
      end
    end

    #UI.messagebox pts_tab.to_s, MB_MULTILINE, "3"
    # Créer des segments de ligne pour relier les points
    tab_edg = Array.new
    tab_edg.clear
    for i in 0..pts_tab.length-2
        tab_edg << @model.add_line(pts_tab[i], pts_tab[i+1])
    end
    tab_edg << @model.add_line(pts_tab[pts_tab.length-1], pts_tab[0])
    
    return tab_edg
  
  end
 

end

# une classe 2d (x,y) qui divise un cercle en n points donnés et renvoie un tableau d'edges de longueurs identiques le long du cercle.
# le premier point n'étant pas aux coordonnées (rayon, 0.0) mais décalé de cette origine par un angle indiqué en radians
class Cercle_xy
  attr_reader :edges 

  def initialize(centre, rayon, nb_points, angle_dep, model)
    @centre = centre
    @rayon = rayon.to_f
    @nb_points = nb_points.to_i
    @nb_points = 3 if @nb_points < 3
    @model = model
    @angle_dep = angle_dep.to_f
    @edges = dessiner_cercle_xy
  end

  def dessiner_cercle_xy
    pts_tab = Array.new
    pts_tab.clear
    
    for compt in 0...@nb_points
      angle = compt * 2.0 * Math::PI / @nb_points
      x = @centre.x + @rayon *  Math.cos(angle + @angle_dep)
      y = @centre.y + @rayon *  Math.sin(angle + @angle_dep)
      pts_tab << Geom::Point3d.new(x, y, @centre.z)
    end
    # Créer des segments de ligne pour relier les points
    tab_edg = Array.new
    tab_edg.clear
    for i in 0..pts_tab.length-2
        tab_edg << @model.add_line(pts_tab[i], pts_tab[i+1])
    end
    tab_edg << @model.add_line(pts_tab[pts_tab.length-1], pts_tab[0])
    return tab_edg
  
  end
 
end

# une classe 2d (x,y) crée une figure oblongue et renvoie un tableau d'edges de longueurs identiques le long du cercle.
class Oblong_xy
  attr_reader :edges 

  def initialize(centre, rayon, nb_points, long_ob, model)
    @centre = centre
    @rayon = rayon.to_f
    @nb_points = nb_points.to_i
    @nb_points = 6 if @nb_points < 6
    @model = model
    @long_ob = long_ob.to_f
    @edges = dessiner_oblong_xy
  end

  def dessiner_oblong_xy
    pts_tab = Array.new
    pts_tab.clear

    nb_point_int_ob = 0
    if (@nb_points - 6) % 4 == 2
      nb_point_int_ob = 1
    end

    nb_point_int_arc = (@nb_points - 6 - nb_point_int_ob*2)/4
    arco = @rayon * Math::PI / (2.0 * (nb_point_int_arc+1))
    oblo = @long_ob/(nb_point_int_ob+1)

    a = true
    while a == true
      arco = @rayon * Math::PI / (2.0 * (nb_point_int_arc+1))
      oblo = @long_ob/(nb_point_int_ob+1)
      if (arco < oblo) && (nb_point_int_arc>0)
        nb_point_int_ob +=2
        nb_point_int_arc -=1
      else
        a = false
      end
    end

    for compt in 0..(nb_point_int_arc+1)
      angle = compt * 2.0 * Math::PI / (4+4*nb_point_int_arc)
      x = @centre.x + @long_ob / 2.0 + @rayon *  Math.cos(angle)
      y = @centre.y + @rayon *  Math.sin(angle)
      pts_tab << Geom::Point3d.new(x, y, @centre.z)
    end
    if (nb_point_int_ob>0)
      for compt in 1..nb_point_int_ob
        x = @centre.x + @long_ob / 2.0 - compt * @long_ob/(nb_point_int_ob+1)
        y = @centre.y + @rayon 
        pts_tab << Geom::Point3d.new(x, y, @centre.z)
      end
    end 
    for compt in 0..((nb_point_int_arc+1)*2)
      angle = compt * 2.0 * Math::PI / (4+4*nb_point_int_arc) + Math::PI/2.0
      x = @centre.x - @long_ob / 2.0 + @rayon *  Math.cos(angle)
      y = @centre.y + @rayon *  Math.sin(angle)
      pts_tab << Geom::Point3d.new(x, y, @centre.z)
    end
    if (nb_point_int_ob>0)
      for compt in 1..nb_point_int_ob
        x = @centre.x - @long_ob / 2.0 + compt * @long_ob/(nb_point_int_ob+1)
        y = @centre.y - @rayon 
        pts_tab << Geom::Point3d.new(x, y, @centre.z)
      end
    end
    for compt in 0..(nb_point_int_arc)
      angle = compt * 2.0 * Math::PI / (4+4*nb_point_int_arc) + 3.0*Math::PI/2.0
      x = @centre.x + @long_ob / 2.0 + @rayon *  Math.cos(angle)
      y = @centre.y + @rayon *  Math.sin(angle)
      pts_tab << Geom::Point3d.new(x, y, @centre.z)
    end

    # Créer des segments de ligne pour relier les points
    tab_edg = Array.new
    tab_edg.clear
    for i in 0..pts_tab.length-2
        tab_edg << @model.add_line(pts_tab[i], pts_tab[i+1])
    end
    tab_edg << @model.add_line(pts_tab[pts_tab.length-1], pts_tab[0])

    return tab_edg
  
  end
 
end

class Maill2D

  attr_accessor :points, :colonne, :ligne
  # le point 0,0 est en bas à gauche, les indices des points sont donc [i][j] avec i la colonne et j la ligne
  def initialize(colonne, ligne)
    @lignes = ligne
    @colonnes = colonne
    @points = Array.new(colonne) { Array.new(ligne) } # Tableau 2D de Point2D
  end
  
  def aire_face(i1, j1, i2, j2, i3, j3)
    p1 = @points[i1][j1]
    p2 = @points[i2][j2]
    p3 = @points[i3][j3]

    # Formule de l'aire d'un triangle (produit vectoriel)
    0.5 * ((p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y)).abs
  end

  def longueur_arete(i1, j1, i2, j2)
    p1 = @points[i1][j1]
    p2 = @points[i2][j2]

    Math.sqrt((p2.x - p1.x)**2 + (p2.y - p1.y)**2)
  end

  def angle_arete(i1, j1, i2, j2, i3, j3)
    p1 = @points[i1][j1]
    p2 = @points[i2][j2]
    p3 = @points[i3][j3]

    v1 = [(p1.x - p2.x), (p1.y - p2.y)]
    v2 = [(p3.x - p2.x), (p3.y - p2.y)]

    produit_scalaire = v1[0] * v2[0] + v1[1] * v2[1]
    norme_v1 = Math.sqrt(v1[0]**2 + v1[1]**2)
    norme_v2 = Math.sqrt(v2[0]**2 + v2[1]**2)

    if norme_v1*norme_v2 != 0
      Math.acos(produit_scalaire / (norme_v1 * norme_v2))
    else
      0.0
    end
  end

  def longueurs_point(i, j)
    longueurs = []

    # Vérifier les voisins et calculer les longueurs
    if i < @colonnes - 1 # arête droite
      longueurs << longueur_arete(i, j, i + 1, j)
    else
      longueurs << 0 # Bord gauche
    end
    if j < @lignes - 1 #arête supérieure
      longueurs << longueur_arete(i, j, i, j + 1)
    else
      longueurs << 0 # Bord inférieur
    end
    if i > 0 #arête gauche
      longueurs << longueur_arete(i, j, i - 1, j)
    else
      longueurs << 0 # Bord droit
    end
    if j > 0 #arête inférieure
      longueurs << longueur_arete(i, j, i, j - 1)
    else
      longueurs << 0 # Bord supérieur
    end

    longueurs
  end

  def angles_point(i, j)
    angles = []

    # Vérifier les voisins et calculer les angles
    if i < @colonnes - 1 && j < @lignes - 1
      angles << angle_arete(i + 1, j, i, j, i, j + 1) # haut et droit
    else
      angles << 0 # Bord supérieur ou droit
    end
    if i > 0 && j < @lignes - 1
      angles << angle_arete(i - 1, j, i, j, i, j + 1) # haut et gauche
    else
      angles << 0 # Bord supérieur ou gauche
    end
    if i > 0 && j > 0
      angles << angle_arete(i - 1, j, i, j, i, j - 1) # bas et gauche
    else
      angles << 0 # Bord inférieur ou gauche
    end
    if i < @colonnes - 1 && j > 0
      angles << angle_arete(i + 1, j, i, j, i, j - 1) # bas et droit
    else
      angles << 0 # Bord inférieur ou droit
    end

    angles
  end

  def aires_point(i, j)
    aires = []

    # Vérifier les faces et calculer les aires
    if i < @colonnes - 1 && j < @lignes - 1
      aires << aire_face(i, j, i+1, j, i+1, j + 1) # haut et droit
      aires << aire_face(i, j, i+1, j+1, i, j + 1) # haut et droit
    else
      aires << 0
      aires << 0  # Bord supérieur ou droit
    end
    if i > 0 && j < @lignes - 1
      aires << aire_face(i, j, i, j+1, i-1, j) # haut et gauche
    else
      aires << 0  # Bord supérieur ou gauche
    end
    if i > 0 && j > 0
      aires << aire_face(i, j, i-1, j, i-1, j - 1) # bas et gauche
      aires << aire_face(i, j, i-1, j-1, i, j - 1) # bas et gauche
    else
      aires << 0 
      aires << 0 # Bord inférieur ou gauche
    end
    if i < @colonnes - 1 && j > 0
      aires << aire_face(i, j, i, j-1, i+1, j) # bas et droit
    else
      aires << 0 # Bord inférieur ou droit
    end
    
    aires
  end
end
  
class Point2D
  attr_accessor :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Membrane
  attr_reader :type, :group

 ############################################### Creation nouvelle forme ####################################""""
  def initialize
  end

  # petite fonction pour savoir si un nombre est pair ou pas
  def pair?(nombre)
    nombre % 2 == 0
  end

  # une fonction qui divise un edges en plusieurs edges
  def Diviser_edge(edge_init, n, model)

    point_deb = edge_init.start.position
    point_fin = edge_init.end.position
    vecteur = point_fin - point_deb
    incrementx = vecteur.x / n
    incrementy = vecteur.y / n
    incrementz = vecteur.z / n
    increment = Geom::Vector3d.new(incrementx,incrementy,incrementz)
    tab_edge = Array.new
    tab_edge.clear
    point_courant = point_deb
    for compt in 0...n
      nouv_point = point_courant + increment
      #UI.messagebox nouv_point.to_s, MB_MULTILINE, "nouv_point"
      tab_edge << model.add_line(point_courant, nouv_point)
      point_courant = nouv_point
    end
  
    return tab_edge

  end 

  # la même mais avec deux points
  def Diviser_edge_points(point_deb, point_fin, n, dernier)
    vecteur = point_fin - point_deb
    incrementx = vecteur.x / n
    incrementy = vecteur.y / n
    incrementz = vecteur.z / n
    increment = Geom::Vector3d.new(incrementx,incrementy,incrementz)
    tab_point = Array.new
    tab_point.clear
    tab_point << point_deb
    point_courant = point_deb
    if dernier == "non"
      n -= 1
    end
    for compt in 0...n
      nouv_point = point_courant + increment
      #UI.messagebox nouv_point.to_s, MB_MULTILINE, "nouv_point"
      tab_point << nouv_point
      point_courant = nouv_point
    end
    return tab_point
  end 

  def maillage(tnb_sommets, tnb_poteaux, thaut_chap, trayon_sommet, toblongue, tcoup_ob_m, trayon_cercle_sommets, tdec, tchoix_cercle, trayon_chap, tpetit_rayon_chap, tnb_div_noue, tnb_div_sabliere)
    
      # on les convertis dans les bons formats
      oblongue = toblongue
      @nb_sommets = tnb_sommets.to_i
      haut_chap = thaut_chap.to_f.m
      #ht_pot_tour = ht_pot_tour.to_f.m
      nb_poteaux = tnb_poteaux.to_i
      choix_cercle = tchoix_cercle.to_s
      dec = tdec.to_s
      rayon_sommet = trayon_sommet.to_f.m
      coup_ob_m = tcoup_ob_m.to_f.m
      rayon_cercle_sommets = trayon_cercle_sommets.to_f.m
      rayon_chap = trayon_chap.to_f.m
      petit_rayon_chap = tpetit_rayon_chap.to_f.m
      @nb_div_noue = tnb_div_noue.to_i
      nb_div_sabliere = tnb_div_sabliere.to_i
      @q_bord = 50.0
      @q_trame = 1.0
      @q_chaine = 1.0
      @precision = 0.1

      # on les recalibre si elles dépassent les limites 
      if choix_cercle == "ellipse"
        cercle = false
      else
        cercle = true
      end
      if dec == "true"
        decalage = true
      else
        decalage = false
      end
      @nb_sommets = 1 if @nb_sommets < 1
      haut_chap = 0.0 if haut_chap < 0.0
      #if toil_tour == "true"
      #  haut_chap = haut_chap - ht_pot_tour
      #end
      nb_poteaux = 3 if nb_poteaux < 3
      if !cercle && nb_poteaux < 5
        nb_poteaux = 5
      end
      if oblongue == "true"
        if !pair?(nb_poteaux)
          nb_poteaux += 1
        end
        if nb_poteaux < 6
          nb_poteaux = 6
        end
      end
      if nb_poteaux % @nb_sommets != 0
        nb_poteaux = @nb_sommets * ((nb_poteaux / @nb_sommets).ceil+1)
      end
      rayon_sommet = 1.0 if rayon_sommet < 1.0
      if @nb_sommets > 1 && rayon_cercle_sommets < rayon_sommet
        rayon_cercle_sommets = rayon_sommet + 1
      end
      rayon_chap = 1.0 if rayon_chap < 1.0
      petit_rayon_chap = 1.0 if petit_rayon_chap < 1.0
      @nb_div_noue = 1 if @nb_div_noue < 1
      nb_div_sabliere = 1 if nb_div_sabliere < 1
      @q_bord = 1.0 if @q_bord < 0.0
      @q_trame = 1.0 if @q_bord < 0.0
      @q_chaine = 1.0 if @q_bord < 0.0
      rap_ps = nb_poteaux/@nb_sommets
      

      # ça c'est un tableau dans lequel vont être stockés tous les points fixes
      @pts_fixes = []
      @pts_fixes.clear

      # tableau de tous les edges
      @tab_seg = []
      @tab_seg.clear

      # à partir du moment où il peut y avoir plusieurs sommets, on a par sommet : un tab pour les edges du sommet + un tab pour les edges de tour de chaque camembert de cercle ou ellipse
      cercle_tour = [] # le tableau qui contient tous les edges qui relient les poteaux 
      cercle_sommet = [] # un tableau qui contient tous les edges pour un sommet
      cercle_tour.clear
      cercle_sommet.clear
      cercle_tour_pts = []
      cercle_tour_pts.clear
      camembert_tour = [] # un tableau qui contient tous les edges qui font le tour d'un camembert
      camembert_tour.clear
      tab_sommets = []   #un tableau qui va contenir les multiples tableaux cercle_sommets pour chaque sommet
      tab_sommets.clear
      tab_camembert = [] # un tableau qui va contenir les multiples tableaux camembert_tour pour chaque sommet
      tab_camembert.clear

      # crée un raccourci pour accéder au group
      @group = Sketchup.active_model.entities.add_group
      @ent_group = @group.entities
      @nb_laizes = 0
      # on commence par creer le tour, cercle ou ellipse, du bas et on stocke les edges dans le tab cercle_tour
      if cercle
        cercle_tour = Cercle_xy.new(Geom::Point3d.new(0.0,0.0,0.0), rayon_chap, nb_poteaux, 0.0, @ent_group).edges
      else
        cercle_tour = Ellipse.new(Geom::Point3d.new(0.0,0.0,0.0), rayon_chap, petit_rayon_chap, nb_poteaux, @ent_group).edges
      end
      # et on les ajoute aux points fixes
      cercle_tour.each {|edge| 
        cercle_tour_pts << edge.start.position
        @pts_fixes << edge.start
      }
      # ensuite on crée les cercles des sommets décalés ou pas
      nb_points_sommet = 0
      nb_div_rampant = 0
      tab_points_camembert = []
      tab_points_camembert.clear
      #on rajoute un tableau qui pour chaque camembert va garder deux numéro, le premier et le dernier point qui ne font pas partie des bords
      tab_pts_cam_repart = []
      tab_pts_cam_repart.clear

      # facile si on a seul sommet
      if @nb_sommets == 1 
        cercle_sommet.clear
        if oblongue == "true"
          cercle_sommet = Oblong_xy.new(Geom::Point3d.new(0.0,0.0,haut_chap), rayon_sommet, nb_poteaux, coup_ob_m, @ent_group).edges
        else
          cercle_sommet = Cercle_xy.new(Geom::Point3d.new(0.0,0.0,haut_chap), rayon_sommet, nb_poteaux, 0.0 , @ent_group).edges
        end
        cercle_sommet.each {|edge| 
          @pts_fixes << edge.start
        }
        tab_sommets << cercle_sommet
        tab_camembert << cercle_tour
        tab_camembert.each {|tab|
          temp_point = []
          tab.each{|edge|
            temp_point << edge.start.position
          }
          tab_points_camembert << temp_point
          tab_pts_cam_repart = [0, 0]
        }
        @nb_laizes = nb_poteaux * nb_div_sabliere
        @nb_div_entre_poteaux = nb_div_sabliere

        # plus dur si on en a plusieurs
      else
        if decalage 
          angle_depp = Math::PI / nb_poteaux
        else
          angle_depp = 0.0
        end
        
        # la on calcule le nombre de points des cercles des sommets
        if cercle
          ll = Math.sqrt(haut_chap**2 + rayon_chap**2)
        else
          ll = Math.sqrt(haut_chap**2 + ((petit_rayon_chap + rayon_chap)/2)**2)
        end
        demi_ecart_poteaux = cercle_tour[0].length / 2.0
        nb_div_rampant = (ll / demi_ecart_poteaux).ceil - 1
        nb_points_sommet = rap_ps * 2 + 2 * nb_div_rampant
        @nb_laizes = nb_points_sommet * nb_div_sabliere
        @nb_div_entre_poteaux = 2 * nb_div_sabliere

        # là on crée tous les cercles de sommets et on ajoute direct leur points aux points fixes
        cercle_sommet.clear
        angle_dec = Math::PI * 2.0 / @nb_sommets
        for compt in 0...@nb_sommets
          x = rayon_cercle_sommets * Math.cos(angle_depp + compt * angle_dec)
          y = rayon_cercle_sommets * Math.sin(angle_depp + compt * angle_dec)
          cercle_sommet = Cercle_xy.new(Geom::Point3d.new(x,y,haut_chap), rayon_sommet, nb_points_sommet, angle_depp + compt * angle_dec, @ent_group).edges
          cercle_sommet.each {|edge| 
            @pts_fixes << edge.start
          }
          tab_sommets << cercle_sommet
        end
        
        point_sommet = Geom::Point3d.new(0.0,0.0,haut_chap)

        # on va creer un camembert et après on le fera tourner autant de fois qu'il y a de sommets
        if !decalage
          if pair?(rap_ps)
            # pas décalé et rap_ps pair
            for com in 0...((rap_ps)/2)
              temp = Diviser_edge(cercle_tour[com],2, @ent_group)
              temp.each {|edge| camembert_tour << edge}
            end
            point_bas_corde = cercle_tour[(rap_ps)/2].start.position
            temp = Diviser_edge(@ent_group.add_line(point_bas_corde, point_sommet), nb_div_rampant ,@ent_group)
            temp.each {|edge| camembert_tour << edge}
            point_bas_corde2 = cercle_tour[nb_poteaux-((rap_ps)/2)].start.position
            temp = Diviser_edge(@ent_group.add_line(point_sommet, point_bas_corde2), nb_div_rampant ,@ent_group)
            @vertex_sommet = temp[0].start
            temp.each {|edge| camembert_tour << edge}
            for com in (nb_poteaux-((rap_ps)/2))...nb_poteaux
              temp = Diviser_edge(cercle_tour[com],2, @ent_group)
              temp.each {|edge| camembert_tour << edge}
            end
            tab_pts_cam_repart = [rap_ps, camembert_tour.length - rap_ps]
          else
            # pas décalé et rap_ps impair     
            for com in 0...(((rap_ps)-1)/2)
              temp = Diviser_edge(cercle_tour[com],2, @ent_group)
              temp.each {|edge| camembert_tour << edge}
            end
            hh = Diviser_edge(cercle_tour[((rap_ps)-1)/2], 2, @ent_group)[0]
            camembert_tour << hh
            point_bas_corde = hh.end.position
            temp = Diviser_edge(@ent_group.add_line(point_bas_corde, point_sommet), nb_div_rampant ,@ent_group)
            temp.each {|edge| camembert_tour << edge}
            hh2 = Diviser_edge(cercle_tour[nb_poteaux-((rap_ps)-1)/2-1],2,@ent_group)[1]
            point_bas_corde2 = hh2.start.position
            temp = Diviser_edge(@ent_group.add_line(point_sommet, point_bas_corde2), nb_div_rampant ,@ent_group)
            @vertex_sommet = temp[0].start
            temp.each {|edge| camembert_tour << edge}
            camembert_tour << hh2
            for com in (nb_poteaux-((rap_ps)-1)/2)...nb_poteaux
              temp = Diviser_edge(cercle_tour[com],2, @ent_group)
              temp.each {|edge| camembert_tour << edge}
            end
            tab_pts_cam_repart = [rap_ps, camembert_tour.length - rap_ps]
          end
        else
          if !pair?(rap_ps)
            # décalé et rap_ps impair
            tempi = Diviser_edge(cercle_tour[0],2,@ent_group)
            camembert_tour << tempi[1]
            pbc = 0
            for com in 1..(((rap_ps)-1)/2)
              temp = Diviser_edge(cercle_tour[com],2,@ent_group)
              temp.each {|edge| camembert_tour << edge
              pbc = edge.end.position}
            end
            point_bas_corde = pbc
            temp = Diviser_edge(@ent_group.add_line(point_bas_corde, point_sommet), nb_div_rampant ,@ent_group)
            temp.each {|edge| camembert_tour << edge}
            point_bas_corde2 = cercle_tour[nb_poteaux-(((rap_ps)-1)/2)].start.position
            temp = Diviser_edge(@ent_group.add_line(point_sommet, point_bas_corde2), nb_div_rampant ,@ent_group)
            @vertex_sommet = temp[0].start
            temp.each {|edge| camembert_tour << edge}
            for com in (nb_poteaux-(((rap_ps)-1)/2))...nb_poteaux
              temp = Diviser_edge(cercle_tour[com],2,@ent_group)
              temp.each {|edge| camembert_tour << edge}
            end
            camembert_tour << tempi[0]
            tab_pts_cam_repart = [rap_ps, camembert_tour.length - rap_ps]
          else
            # décalé et rap_ps pair
            tempi = Diviser_edge(cercle_tour[0],2,@ent_group)
            camembert_tour << tempi[1]
            if ((rap_ps)/2) > 1
              for com in 1...((rap_ps)/2)
                temp = Diviser_edge(cercle_tour[com],2,@ent_group)
                temp.each {|edge| camembert_tour << edge}
              end
            end
            hh = Diviser_edge(cercle_tour[(rap_ps)/2], 2, @ent_group)[0]
            camembert_tour << hh
            point_bas_corde = hh.end.position
            temp = Diviser_edge(@ent_group.add_line(point_bas_corde, point_sommet), nb_div_rampant ,@ent_group)
            temp.each {|edge| camembert_tour << edge}
            hh = Diviser_edge(cercle_tour[nb_poteaux-(rap_ps)/2],2,@ent_group)[1]
            point_bas_corde2 = hh.start.position
            temp = Diviser_edge(@ent_group.add_line(point_sommet, point_bas_corde2), nb_div_rampant ,@ent_group)
            @vertex_sommet = temp[0].start
            temp.each {|edge| camembert_tour << edge}
            camembert_tour << hh
            for com in (nb_poteaux-(rap_ps)/2+1)...nb_poteaux
              temp = Diviser_edge(cercle_tour[com],2,@ent_group)
              temp.each {|edge| camembert_tour << edge}
            end
            camembert_tour << tempi[0]
            tab_pts_cam_repart = [rap_ps, camembert_tour.length - rap_ps]
          end        
        end

        @pts_fixes << @vertex_sommet
        tab_camembert << camembert_tour
        #on repasse en points 3d
        tab_camembert.each {|tab|
        temp_point = []
        tab.each{|edge|
          temp_point << edge.start.position
        }
        tab_points_camembert << temp_point
        }
        
        for compt in 1...@nb_sommets
          rot = Geom::Transformation.rotation [0, 0, 0], [0, 0 ,1], (Math::PI * 2.0 / @nb_sommets)*compt
          temp_point_new = []
          tab_points_camembert[0].each {|pt|
            pt2 = Geom::Point3d.new(pt.x,pt.y,pt.z)
            temp_point_new << pt2.transform!(rot)
          }
          tab_points_camembert << temp_point_new
        end
        # si c'est une ellipse alors on a pas mal de réajustement à faire
        if !cercle
          for compt in 1...@nb_sommets
            if !decalage
              if pair?(rap_ps)
                tab_points_camembert[compt][0] = cercle_tour_pts[rap_ps*compt]
                for com in 1..((rap_ps)/2)
                  tab_points_camembert[compt][2*com] = cercle_tour_pts[rap_ps*compt+com]
                  tab_points_camembert[compt][2*com-1] = Diviser_edge_points(tab_points_camembert[compt][(com-1)*2], tab_points_camembert[compt][2*com], 2 ,"non")[1]
                end
                point_bas_corde = tab_points_camembert[compt][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_bas_corde, point_sommet, nb_div_rampant,"oui")
                c = tab_pts_cam_repart[0] + 1
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                point_bas_corde2 = tab_points_camembert[compt-1][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_sommet, point_bas_corde2, nb_div_rampant ,"oui")
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                for com in 1..((rap_ps)/2)
                  temp = cercle_tour_pts[(rap_ps)/2+rap_ps*(compt-1)+com]
                  if c+1 < tab_points_camembert[compt].length
                    tab_points_camembert[compt][c+1] = temp
                  end
                  tab_points_camembert[compt][c] = Diviser_edge_points(tab_points_camembert[compt][c-1], temp, 2 ,"non")[1]
                  c += 2
                end
              else
                tab_points_camembert[compt][0] = cercle_tour_pts[rap_ps*compt]
                for com in 1..((rap_ps-1)/2)
                  tab_points_camembert[compt][2*com] = cercle_tour_pts[rap_ps*compt+com]
                  tab_points_camembert[compt][2*com-1] = Diviser_edge_points(tab_points_camembert[compt][(com-1)*2], tab_points_camembert[compt][2*com], 2 ,"non")[1]
                end
                h = rap_ps*compt+(rap_ps-1)/2
                tab_points_camembert[compt][tab_pts_cam_repart[0]] = Diviser_edge_points(cercle_tour_pts[h],cercle_tour_pts[h+1],2,"non")[1]
                point_bas_corde = tab_points_camembert[compt][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_bas_corde, point_sommet, nb_div_rampant,"oui")
                c = tab_pts_cam_repart[0] + 1
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                point_bas_corde2 = tab_points_camembert[compt-1][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_sommet, point_bas_corde2, nb_div_rampant ,"oui")
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                for com in 1..((rap_ps-1)/2)
                  tab_points_camembert[compt][c] = cercle_tour_pts[(rap_ps-1)/2+rap_ps*(compt-1)+com]
                  tab_points_camembert[compt][c+1] = Diviser_edge_points(tab_points_camembert[compt][c], cercle_tour_pts[(rap_ps-1)/2+rap_ps*(compt-1)+com+1], 2 ,"non")[1]
                  c += 2
                end
              end
            else
              if pair?(rap_ps)
                tab_points_camembert[compt][0] = Diviser_edge_points(cercle_tour_pts[rap_ps*compt], cercle_tour_pts[rap_ps*compt+1], 2 ,"non")[1]
                for com in 1..((rap_ps)/2)
                  tab_points_camembert[compt][2*com-1] = cercle_tour_pts[rap_ps*compt+com]
                  tab_points_camembert[compt][2*com] = Diviser_edge_points(tab_points_camembert[compt][2*com-1], cercle_tour_pts[rap_ps*compt+com+1] , 2 ,"non")[1]
                end
                point_bas_corde = tab_points_camembert[compt][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_bas_corde, point_sommet, nb_div_rampant,"oui")
                c = tab_pts_cam_repart[0] + 1
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                point_bas_corde2 = tab_points_camembert[compt-1][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_sommet, point_bas_corde2, nb_div_rampant ,"oui")
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                for com in 1..((rap_ps)/2)
                  tab_points_camembert[compt][c] = cercle_tour_pts[rap_ps/2 + rap_ps*(compt-1) + com]
                  if c+1 < tab_points_camembert[compt].length
                    tab_points_camembert[compt][c+1] = Diviser_edge_points(tab_points_camembert[compt][c], cercle_tour_pts[rap_ps/2+ rap_ps*(compt-1) + com + 1], 2 ,"non")[1]
                  end
                  c += 2
                end
              else
                temp = Diviser_edge_points(cercle_tour_pts[rap_ps*compt], cercle_tour_pts[rap_ps*compt+1], 2 ,"oui")
                tab_points_camembert[compt][0] = temp[1]
                tab_points_camembert[compt][1] = temp[2]
                for com in 1..((rap_ps-1)/2)
                  tab_points_camembert[compt][2*com+1] = cercle_tour_pts[rap_ps*compt+com+1]
                  tab_points_camembert[compt][2*com] = Diviser_edge_points(tab_points_camembert[compt][2*com-1], tab_points_camembert[compt][2*com+1], 2 ,"non")[1]
                end
                point_bas_corde = tab_points_camembert[compt][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_bas_corde, point_sommet, nb_div_rampant,"oui")
                c = tab_pts_cam_repart[0] + 1
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                point_bas_corde2 = tab_points_camembert[compt-1][tab_pts_cam_repart[0]]
                temp = Diviser_edge_points(point_sommet, point_bas_corde2, nb_div_rampant ,"oui")
                for com in 1...temp.length
                  tab_points_camembert[compt][c] = temp[com]
                  c += 1
                end
                for com in 1..((rap_ps-1)/2)
                  tab_points_camembert[compt][c+1] = cercle_tour_pts[(rap_ps-1)/2+rap_ps*(compt-1)+com+1]
                  tab_points_camembert[compt][c] = Diviser_edge_points(tab_points_camembert[compt][c-1], tab_points_camembert[compt][c+1], 2 ,"non")[1]
                  c += 2
                end
              end
            end
          end
        end
      end
      
      tab_sommets_temp = []
      tab_sommets_temp.clear
      tab_points_camembert_temp = []
      tab_points_camembert_temp.clear
      for compt in 0...@nb_sommets
        t_smt2 = []
        t_cbt2 = []
        tab_sommets[compt].each {|edge|
          temp = Diviser_edge(edge, nb_div_sabliere, @ent_group)
          temp.each {|edge| t_smt2 << edge}
        }
        for compt6 in 0...tab_points_camembert[compt].length-1 
          temp2 = Diviser_edge_points(tab_points_camembert[compt][compt6], tab_points_camembert[compt][compt6+1], nb_div_sabliere, "non")
          temp2.each {|pt| t_cbt2 << pt}
        end
        temp2 = Diviser_edge_points(tab_points_camembert[compt][tab_points_camembert[compt].length-1], tab_points_camembert[compt][0], nb_div_sabliere, "non")
        temp2.each {|pt| t_cbt2 << pt}
        tab_sommets_temp << t_smt2
        tab_points_camembert_temp << t_cbt2
      end
      
      tab_points_camembert = tab_points_camembert_temp
      tab_sommets = tab_sommets_temp
      tempo = [tab_pts_cam_repart[0]*nb_div_sabliere, tab_pts_cam_repart[1]*nb_div_sabliere]
      tab_pts_cam_repart = tempo
        
      tab_edge_cordes = []
      sauv_tab_edge_cordes = []
      sauv0_tab_edge_cordes = []
      @tab_laizes = []
      @tab_laizes.clear

      # on rajoute des cordes puis on divise les cordes et on ajoute des faces
      
      for compt4 in 0...@nb_sommets
        tab_inter_laizes = []
        tab_inter_laizes.clear
        for compt in 0...tab_sommets[compt4].length
          tab_edge_cordes.clear
          a = tab_sommets[compt4][compt].start
          b = tab_points_camembert[compt4][compt]
          temp = Diviser_edge(@ent_group.add_line(b, a), @nb_div_noue ,@ent_group)
          temp.each {|edge| tab_edge_cordes << edge}
          laize = []
          laize2 = []
          laize.clear
          laize2.clear
          for compt3 in 0...@nb_div_noue
            if (compt > 0) 
              facet = @ent_group.add_face(tab_edge_cordes[compt3].end, sauv_tab_edge_cordes[compt3].end, sauv_tab_edge_cordes[compt3].start)
              laize << facet
              edget = facet.edges
              e1 = Edge_i.new
              if compt3 < @nb_div_noue - 1
                e1.ed = edget[0]
                e1.type = "trame"
                e1.q = @q_trame
                @tab_seg << e1
                #edget[0].material = "HotPink"
                edget[0].hidden = true
                e2 = Edge_i.new
                e2.ed = edget[1]
                e2.type = "chaine"
                e2.q = @q_chaine
                @tab_seg << e2
                e3 = Edge_i.new
                #edget[1].material = "DarkBlue"
                edget[1].hidden = true
                e3.ed = edget[2]
                e3.type = "diag"
                @tab_seg << e3
                #edget[2].material = "Green" 
                edget[2].hidden = true
              end
              if compt3 == @nb_div_noue - 1
                e1.ed = edget[0]
                e1.type = "bord"
                e1.q = @q_bord
                edget[0].material = "DarkMagenta"
                @tab_seg << e1
                e2 = Edge_i.new
                e2.ed = edget[1]
                e2.type = "diag"
                @tab_seg << e2
                #edget[1].material = "Green"
                edget[1].hidden = true
                e3 = Edge_i.new
                e3.ed = edget[2]
                e3.type = "chaine"
                e3.q = @q_chaine
                @tab_seg << e3
                #edget[2].material = "DarkBlue" 
                edget[2].hidden = true
              end
              facet = @ent_group.add_face(tab_edge_cordes[compt3].end, sauv_tab_edge_cordes[compt3].start, tab_edge_cordes[compt3].start)
              laize << facet
              if compt3 == 0
                edget = facet.edges
                e2 = Edge_i.new
                e2.ed = edget[1]
                if (@nb_sommets!= 1) && (compt > tab_pts_cam_repart[0]) && (compt <= tab_pts_cam_repart[1])
                  e2.type = "trame"
                  e2.q = @q_trame
                  #edget[1].material = "HotPink"
                  edget[1].hidden = true
                else
                  e2.type = "bord"
                  e2.q = @q_bord
                  edget[1].material = "DarkMagenta"
                end
                @tab_seg << e2
              end
            end
            if (compt == tab_sommets[compt4].length-1) #&& (compt3 > -1)
              facet = @ent_group.add_face(sauv0_tab_edge_cordes[compt3].end, tab_edge_cordes[compt3].end, tab_edge_cordes[compt3].start)    
              laize2 << facet
              edget = facet.edges
              e1 = Edge_i.new
              if compt3 < @nb_div_noue - 1
                e1.ed = edget[0]
                e1.type = "trame"
                e1.q = @q_trame
                @tab_seg << e1
                #edget[0].material = "HotPink"
                edget[0].hidden = true
                e2 = Edge_i.new
                e2.ed = edget[1]
                e2.type = "chaine"
                e2.q = @q_chaine
                @tab_seg << e2
                e3 = Edge_i.new
                #edget[1].material = "DarkBlue"
                edget[1].hidden = true
                e3.ed = edget[2]
                e3.type = "diag"
                @tab_seg << e3
                #edget[2].material = "Green" 
                edget[2].hidden = true
              end
              if compt3 == @nb_div_noue - 1
                e1.ed = edget[0]
                e1.type = "bord"
                e1.q = @q_bord
                edget[0].material = "DarkMagenta"
                @tab_seg << e1
                e2 = Edge_i.new
                e2.ed = edget[1]
                e2.type = "diag"
                @tab_seg << e2
                #edget[1].material = "Green"
                edget[1].hidden = true
                e3 = Edge_i.new
                e3.ed = edget[2]
                e3.type = "chaine"
                e3.q = @q_chaine
                @tab_seg << e3
                #edget[2].material = "DarkBlue" 
                edget[2].hidden = true
              end
              facet = @ent_group.add_face(sauv0_tab_edge_cordes[compt3].end, tab_edge_cordes[compt3].start, sauv0_tab_edge_cordes[compt3].start)
              laize2 << facet
              if compt3 == 0
                edget = facet.edges
                e2 = Edge_i.new
                e2.ed = edget[1]
                e2.type = "bord"
                e2.q = @q_bord
                edget[1].material = "DarkMagenta"
                @tab_seg << e2
              end
            end
          end

          if compt == 0
            sauv0_tab_edge_cordes.clear
            sauv0_tab_edge_cordes = tab_edge_cordes.clone
          else
            tab_inter_laizes << laize
            if compt == tab_sommets[compt4].length-1
              tab_inter_laizes << laize2
            end
          end
          sauv_tab_edge_cordes.clear
          sauv_tab_edge_cordes = tab_edge_cordes.clone
        end
        @tab_laizes << tab_inter_laizes
        
      end

      @ent_group.each {|enti| 
        if enti.is_a? Sketchup::Face
          if enti.normal.z>0
            enti.reverse!
          end
        end
      }

   
  end
  
  ################################################### Réglage tension ##############################################

  def regl
    param = inputbox ["tension des bords","tension membrane chaîne","tension membrane trame","précision de calcul"], [@q_bord, @q_chaine, @q_trame, @precision], "Paramètres de tension chapiteau"
    if param != false
      @q_bord, @q_chaine, @q_trame, @precision = param
      @q_bord = @q_bord.to_f
      @q_chaine = @q_chaine.to_f
      @q_trame = @q_trame.to_f
      @precision = @precision.to_f
      @q_bord = 1.0 if @q_bord < 0.0
      @q_trame = 1.0 if @q_bord < 0.0
      @q_chaine = 1.0 if @q_bord < 0.0
      @tab_seg.each {|ed|
        if ed.type == "bord" 
          ed.q = @q_bord
        elsif ed.type == "chaine"
          ed.q = @q_chaine
        elsif ed.type == "trame"
          ed.q = @q_trame
        end
      }
    end
    tension
  end

  ################################################### Mise sous tension ############################################

  def tension

    ts_les_points = []
    # d'abord on parcourt tous les objets scketchup, si c'est des edges, on rajoute leurs points dans le tableau ts_les_points
    @ent_group.each {|e|
      if e.is_a? Sketchup::Edge
        ts_les_points.push *e.vertices
      end
    }

    # ensuite enlève tous les doublons
    ts_les_points.uniq!

    #puis on crée un tableau des points libres en enlevant les points fixes
    ts_les_points_libre = []
    ts_les_points_libre.clear

    ts_les_points.each {|v| 
      if !(@pts_fixes.include? v)
        ts_les_points_libre << v
      end
    }

    # et le tableau tab_x2 qui associe les edges (non diagonales) liés à chaque point, triés dans l'ordre, avec tous leurs paramètres
    tab_x2 = Array.new
    tab_x2.clear
  
    # la on crée 2 tableaux, surement pour pouvoir rechercher plus facilement les correspondances edge-type et edge-tension
    # du coup le premier est un tableau de couple de valeurs [edge, type] et l'autre [edge, q]
    tab_seg_h_type = {}
    tab_seg_h_type = @tab_seg.map{|edd| [edd.ed, edd.type]}.to_h

    tab_seg_h_q = {}
    tab_seg_h_q = @tab_seg.map{|edd| [edd.ed, edd.q]}.to_h

    # on va donc essayer de remplir les tableaux tab_x2
    ts_les_points_libre.each {|v| 
      
      #on trouve tous les edges relies à un point v
      edge_liee = v.edges

      tab_temp_edges = Array.new
      tab_temp_edges.clear
      # ensuite on vire les diagonales en cherchant dans le tableau tab_seg_h_type et on remplie un tab_temp_edges avec ceux qui ne sont pas des diagonales
      edge_liee.each { |e|
        h = tab_seg_h_type[e]
        if h != "diag"
          tab_temp_edges << e
        end
      }
      # là on les préclasse en les mettant trame-chaine-trame-chaine
      tab_temp_edges2 = Array.new
      tab_temp_edges2.clear
      j = 1
      # si c'est un point du bord ou un point quelconque
      if tab_temp_edges.length < 5
        while tab_temp_edges.length > 0
          for i in 0...tab_temp_edges.length 
            h = tab_seg_h_type[tab_temp_edges[i]]
            sj = j
            if (j == 1) && (( h == "trame")||(h == "bord"))
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 2) && (h == "chaine")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 3) && ((h == "trame")||(h == "bord"))
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 4) && (h == "chaine")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            end
            if j > sj
              break
            end
          end
        end
      #si c'est un point de rencontre de 2 camemberts dans le cas de plusieurs sommets
      else
        while tab_temp_edges.length > 0
          for i in 0...tab_temp_edges.length 
            h = tab_seg_h_type[tab_temp_edges[i]]
            sj = j
            if (j == 1) && (h == "bord")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 2) && (h == "chaine")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 3) && (h == "trame")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 4) && (h == "chaine")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            elsif (j == 5) && (h == "bord")
              tab_temp_edges2 << tab_temp_edges.delete_at(i)
              j += 1
            end
            if j > sj
              break
            end
          end
        end
      end
      #la ça serait pas mal de les trier dans le sens trigo au moins pour les pts de rencontre camembert
      if tab_temp_edges2.length > 4
        vec = tab_temp_edges2[0].vertices
        if vec[0] == v
          vec1 = Geom::Vector3d.new(vec[1].position-vec[0].position)
        else
          vec1 = Geom::Vector3d.new(vec[0].position-vec[1].position)
        end
        vec = tab_temp_edges2[2].vertices
        if vec[0] == v
          vec2 = Geom::Vector3d.new(vec[1].position-vec[0].position)
        else
          vec2 = Geom::Vector3d.new(vec[0].position-vec[1].position)
        end
        cro_vec = vec1.cross(vec2)
        if cro_vec.z < 0.0
          temp = tab_temp_edges2[0]
          tab_temp_edges2[0] = tab_temp_edges2[4]
          tab_temp_edges2[4] = temp
        end

        vec = tab_temp_edges2[1].vertices
        if vec[0] == v
          vec1 = Geom::Vector3d.new(vec[1].position-vec[0].position)
        else
          vec1 = Geom::Vector3d.new(vec[0].position-vec[1].position)
        end
        cro_vec = vec1.cross(vec2)
        if cro_vec.z < 0.0
          temp = tab_temp_edges2[1]
          tab_temp_edges2[1] = tab_temp_edges2[3]
          tab_temp_edges2[3] = temp
        end
      end
      
      #la on crée un tableau tab_x2 ou pour chaque point est associé les 3,4 ou 5 edges, chacun ayant son type, son q et son point de fin
      tab_temp_edges3 = Array.new
      tab_temp_edges3.clear
      tab_temp_edges2.each {|e|
        ed = Edge_i.new
        ed.type = tab_seg_h_type[e]
        ed.q = tab_seg_h_q[e]
        if e.start == v
          ed.x = e.end
        else
          ed.x = e.start
        end
        tab_temp_edges3 << ed
      }
      tab_x2 << tab_temp_edges3
      
    }
    
    vectors = Array.new
    vectors.clear

    #si on a plusieurs sommets, on va creer un tableau qui référencie tous les points liés au sommet
    if @nb_sommets > 1
      tab_voisins_sommets = []
      tab_voisins_sommets.clear
      edge_liee = @vertex_sommet.edges
      temp_voisins = []
      temp_voisins.clear
      edge_liee.each { |e|
          h = tab_seg_h_type[e]
          if h != "diag"
            temp_voisins << e
          end
        }
      temp_voisins.each {|e|
        if e.start == @vertex_sommet
          tab_voisins_sommets << e.end
        else
          tab_voisins_sommets << e.start
        end
      }
    end
  
   
      #ensuite on définit la précision du calcul, quand est-ce que l'on va sortir de la boucle
		epsilon = @precision#0.1 #@delta_z * 10 ** (-$m_options["precision"])
		infl = 0.0 #$m_options["infl"]

    begin
      stop = true
      vectors.clear
      for i in 0...tab_x2.length
        #UI.messagebox "6".to_s, MB_MULTILINE, "6"
        p = Geom::Point3d.new 0, 0, 0
        div = 0.0

        o1 = tab_x2[i][0]
        if o1 != nil
          coeff = o1.q 
          p.x += coeff * o1.x.position.x
          p.y += coeff * o1.x.position.y
          p.z += coeff * o1.x.position.z
          div += coeff
        end
        if (o2 = tab_x2[i][1]) != nil
          coeff = o2.q
          p.x += coeff * o2.x.position.x
          p.y += coeff * o2.x.position.y
          p.z += coeff * o2.x.position.z
          div += coeff
          end
        if (o3 =  tab_x2[i][2]) != nil
          coeff = o3.q
          p.x += coeff * o3.x.position.x
          p.y += coeff * o3.x.position.y
          p.z += coeff * o3.x.position.z
          div += coeff
        end
        if (o4 = tab_x2[i][3]) != nil
          coeff = o4.q
          p.x += coeff * o4.x.position.x
          p.y += coeff * o4.x.position.y
          p.z += coeff * o4.x.position.z
          div += coeff
        end
        if (o5 = tab_x2[i][4]) != nil
          coeff = o5.q
          p.x += coeff * o5.x.position.x
          p.y += coeff * o5.x.position.y
          p.z += coeff * o5.x.position.z
          div += coeff
        end
        #si c'était un point qui avait 4 voisins, alors on lui rajoute un déplacement perpendiculaire due au gonflage
        if (infl != 0.0) && (tab_x2[i].length == 4)
          n = (o3.x.position-o1.x.position).cross(o2.x.position-o4.x.position) ###### ouh la va falloir remettre la remise dans l'ordre des points sinon on a des points qui vont enfler 
          ########### dans un sens et d'autres dans l'autre !!
          q = infl/Math.sqrt(n.length)
          n.normalize!

          p.x += q*n.x
          p.y += q*n.y
          p.z += q*n.z
        end

        p.x /= div
        p.y /= div
        p.z /= div
        #UI.messagebox p.to_s, MB_MULTILINE, "6"
        # tant que le déplacement final est trop grand, on continue
        if (p - ts_les_points_libre[i]).length > epsilon
          stop = false
        end
        vectors << ts_les_points_libre[i].position.vector_to(p)
      end
      
      @ent_group.transform_by_vectors(ts_les_points_libre, vectors) 
          
      if @nb_sommets > 1
        z = 0.0
        tab_voisins_sommets.each{|v| z += v.position.z}
        tr = Geom::Transformation.translation [0.0, 0.0, z/tab_voisins_sommets.length-@vertex_sommet.position.z]
        @ent_group.transform_entities tr, @vertex_sommet
      end  
    end while not stop
  end

  ################################################### Peinture chap ##############################################

  def peinture

    coul_dialog = UI::HtmlDialog.new(
      {
        :dialog_title => "Sélection des couleurs",
        :resizable => true,
        :width => 400,
        :height => 350,
        :left => 400,
        :top => 200,
        :min_width => 50,
        :min_height => 50,
        :max_width =>1000,
        :max_height => 1000,
        :style => UI::HtmlDialog::STYLE_DIALOG
      }
    )
    @largeur_laize = 1
    deca = 1 

    path = Sketchup.find_support_file "ChapAndCo/ChapAndCo_choix_couleurs.html", "Plugins"
    coul_dialog.set_file path

    coul_dialog.add_action_callback("appliquer_couleurs") {|d, params|
  
      v = params.to_s.split(",")
      nb, @largeur_laize, deca, coul1, coul2, coul3 = v

      nb = nb.to_i
      if (nb<1)||(nb>3)
        nb = 1
      end
      @largeur_laize = @largeur_laize.to_i
      if (@largeur_laize > @nb_laizes)||(@largeur_laize<1)
        @largeur_laize = 1
      end
      deca = deca.to_i
      if (deca > @nb_laizes)||(deca<0)
        deca = 0
      end
      tab_coul = []
      tab_coul.clear
      couleur1 = Sketchup.active_model.materials.add "couleur 1"
      couleur1.color = coul1
      couleur2 = Sketchup.active_model.materials.add "couleur 2"
      couleur2.color = coul2
      couleur3 = Sketchup.active_model.materials.add "couleur 3"
      couleur3.color = coul3
      tab_coul << coul1 
      tab_coul << coul2
      tab_coul << coul3
      #UI.messagebox couleur1.to_s, MB_MULTILINE, "taille"

      for compt in 0...@tab_laizes.length
        for compt2 in 0...@tab_laizes[compt].length
          bb = ((compt2+compt*deca)/@largeur_laize).floor % nb
          for compt3 in 0...@tab_laizes[compt][compt2].length
            @tab_laizes[compt][compt2][compt3].material = tab_coul[bb]
            @tab_laizes[compt][compt2][compt3].back_material = tab_coul[bb]
          end
        end
      end
      
    }

    coul_dialog.show #{
     # if @nb_sommets == 1
      #  coul_dialog.execute_script("window.sketchup_initial_value = true;")
     # else
     #   coul_dialog.execute_script("window.sketchup_initial_value = false;")
     # end
    #}
    UI.start_timer(5, false) {
      if @nb_sommets == 1
        #UI.messagebox @nb_sommets.to_s, MB_MULTILINE, "taille"
        coul_dialog.execute_script("document.getElementById('dec').classList.add('disabled');")
      end
    }
    
   
  end

  ################################################### Mise à plat des laizes ##############################################

  def laiz

    #on définit les poids de chaque résidu de la fonction d'énergie
    pd_aires = 1.0
    pd_longu = 60.0
    pd_angle = 15.0
    ecart = 0.1 #pour le calcul de la dérivée
    iterations = 100 #nombre d'itérations
           
    param = inputbox ["poids aires","poids longueur","poids angle","écart","itération"], [pd_aires, pd_longu, pd_angle, ecart, iterations], "Paramètres de mise à plat"
    if param != false
      pd_aires, pd_longu, pd_angle, ecart, iterations = param
      pd_aires = pd_aires.to_f
      pd_longu = pd_longu.to_f
      pd_angle = pd_angle.to_f
      ecart = ecart.to_f
      iterations = iterations.to_i
    end
           
    #UI.messagebox @nb_div_entre_poteaux.to_s, MB_MULTILINE, "taille"
    groupe_laizes = Sketchup.active_model.entities.add_group
    tab_seg_h_type = {}
    tab_seg_h_type = @tab_seg.map{|edd| [edd.ed, edd.type]}.to_h
    #UI.messagebox tab_seg_h_type.to_s, MB_MULTILINE, "longueurs"

    for compt in 0...@tab_laizes.length
      compt4 = 0
      while compt4 < @tab_laizes[compt].length do
        progression_entre_pot = compt4 % @nb_div_entre_poteaux
        coul = @tab_laizes[compt][compt4][0].material
        inc = 1
        h = true
        while h do
          if (compt4+inc < @tab_laizes[compt].length)
            if (@tab_laizes[compt][compt4+inc][0].material == coul)
              if progression_entre_pot + inc < @nb_div_entre_poteaux
                inc += 1
              else
                h = false
              end
            else 
              h = false
            end
          else
            h = false
          end
        end
        new_group = groupe_laizes.entities.add_group
        
        lignes = @nb_div_noue + 1
        colonnes = inc + 1
        # tableaux pour stocker les valeurs d'aires, de longueurs et d'angles de la membrane 3D
        tab_point3d_aires = Array.new(colonnes) { Array.new(lignes) { Array.new(6, 0.0) } }
        tab_point3d_longueurs = Array.new(colonnes) { Array.new(lignes) { Array.new(4, 0.0) } }
        tab_point3d_angles = Array.new(colonnes) { Array.new(lignes) { Array.new(4, 0.0) } }
        tab_point2d = Maill2D.new(colonnes, lignes)
        sauv_seg = Array.new(2)

        normal_sum = Geom::Vector3d.new(0, 0, 0)
        for compt2 in compt4...compt4+inc 
          for compt3 in 0...@tab_laizes[compt][compt2].length
            normal_sum += @tab_laizes[compt][compt2][compt3].normal
          end
        end
        average_normal = normal_sum.normalize.reverse
        z_axis = average_normal
        x_axis = Geom::Vector3d.new(0, -1, 0).cross(z_axis).normalize # Axe X arbitraire, perpendiculaire à Z
        y_axis = z_axis.cross(x_axis)
        origin = @tab_laizes[compt][compt4][0].vertices[2].position

        for compt2 in compt4...compt4+inc 
          for compt3 in 0...@tab_laizes[compt][compt2].length
            new_face = new_group.entities.add_face(@tab_laizes[compt][compt2][compt3].vertices.map(&:position))
            i = compt2-compt4
            reste = compt3 % 2
            j = (compt3 / 2.0).floor
            segm = @tab_laizes[compt][compt2][compt3].edges
            #UI.messagebox segm.to_s, MB_MULTILINE, "segm" if compt == 0
            segm2 = Array.new(3)
            style = Array.new(3)
            style[0] = tab_seg_h_type[segm[0]]
            style[1] = tab_seg_h_type[segm[1]]
            style[2] = tab_seg_h_type[segm[2]]  
            #UI.messagebox style.to_s, MB_MULTILINE, "style" if compt == 0
            segm2[2] = segm[2]
            segm2[2] = segm[0] if style[0] == "diag"
            segm2[2] = segm[1] if style[1] == "diag"
            segm2[1] = segm[1]
            segm2[1] = segm[0] if style[0] == "chaine"
            segm2[1] = segm[2] if style[2] == "chaine"
            segm2[0] = segm[0]
            segm2[0] = segm[1] if (style[1] == "trame") || (style[1] == "bord")
            segm2[0] = segm[2] if (style[2] == "trame") || (style[2] == "bord")
            #UI.messagebox segm2.to_s, MB_MULTILINE, "segm2" if compt == 0
                        
            if pair?(reste)
              tab_point3d_aires[i][j][1] = tab_point3d_aires[i+1][j+1][3] = tab_point3d_aires[i][j+1][5] = new_face.area
              tab_point3d_longueurs[i+1][j+1][2] = tab_point3d_longueurs[i][j+1][0] = segm2[0].length.to_inch
              tab_point3d_longueurs[i][j][1] = tab_point3d_longueurs[i][j+1][3] = segm2[1].length.to_inch
              if compt2 == compt4+inc-1
                if ((segm2[0].start == segm2[2].start) || (segm2[0].start == segm2[2].end))
                  local_coords = segm2[0].start.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                  tab_point2d.points[i+1][j+1] = Point2D.new(x, y)
                else
                  local_coords = segm2[0].end.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                  tab_point2d.points[i+1][j+1] = Point2D.new(x, y)
                end
              end
              if compt3 == @tab_laizes[compt][compt2].length-2
                if ((segm2[0].start == segm2[1].start) || (segm2[0].start == segm2[1].end))
                  local_coords = segm2[0].start.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                  tab_point2d.points[i][j+1] = Point2D.new(x, y)
                else
                  local_coords = segm2[0].end.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                  tab_point2d.points[i][j+1] = Point2D.new(x,y)
                end
              end
              if ((segm2[1].start == segm2[2].start) || (segm2[1].start == segm2[2].end))
                local_coords = segm2[1].start.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                tab_point2d.points[i][j] = Point2D.new(x, y)
              else
                local_coords = segm2[1].end.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                tab_point2d.points[i][j] = Point2D.new(x, y)
              end
              sauv_seg[0] = segm2[0]
              sauv_seg[1] = segm2[1]
              if (segm2[1].start == segm2[0].start) || (segm2[1].end == segm2[0].end) 
                tab_point3d_angles[i][j+1][3] = segm2[1].line[1].angle_between(segm2[0].line[1])#.radians
              else
                tab_point3d_angles[i][j+1][3] = segm2[1].line[1].angle_between(segm2[0].line[1].reverse)#.radians
              end
            else
              tab_point3d_aires[i][j][0] = tab_point3d_aires[i+1][j+1][4] = tab_point3d_aires[i+1][j][2] = new_face.area
              tab_point3d_longueurs[i][j][0] = tab_point3d_longueurs[i+1][j][2] = segm2[0].length.to_inch
              tab_point3d_longueurs[i+1][j][1] = tab_point3d_longueurs[i+1][j+1][3] = segm2[1].length.to_inch
              if compt2 == compt4+inc-1
                if ((segm2[0].start == segm2[1].start) || (segm2[0].start == segm2[1].end))
                  local_coords = segm2[0].start.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                  tab_point2d.points[i+1][j] = Point2D.new(x, y)
                else
                  local_coords = segm2[0].end.position.vector_to(origin).to_a
                  x = local_coords.dot(x_axis)+origin.x
                  y = local_coords.dot(y_axis)+origin.y
                  tab_point2d.points[i+1][j] = Point2D.new(x, y)
                end
              end
              if (sauv_seg[1].start == segm2[0].start) || (sauv_seg[1].end == segm2[0].end)
                tab_point3d_angles[i][j][0] = segm2[0].line[1].angle_between(sauv_seg[1].line[1])#.radians
              else
                tab_point3d_angles[i][j][0] = segm2[0].line[1].angle_between(sauv_seg[1].line[1].reverse)#.radians
              end
              if (segm2[0].start == segm2[1].start) || (segm2[0].end == segm2[1].end)
                tab_point3d_angles[i+1][j][1] = segm2[1].line[1].angle_between(segm2[0].line[1])#.radians
              else
                tab_point3d_angles[i+1][j][1] = segm2[1].line[1].angle_between(segm2[0].line[1].reverse)#.radians
              end
              if (segm2[1].start == sauv_seg[0].start) || (segm2[1].end == sauv_seg[0].end)
                tab_point3d_angles[i+1][j+1][2] = sauv_seg[0].line[1].angle_between(segm2[1].line[1])#.radians
              else
                tab_point3d_angles[i+1][j+1][2] = sauv_seg[0].line[1].angle_between(segm2[1].line[1].reverse)#.radians
              end
            end
            new_face.material = @tab_laizes[compt][compt2][compt3].material
            new_face.back_material = @tab_laizes[compt][compt2][compt3].back_material
          end
        end

        #UI.messagebox tab_point2d.points.to_s, MB_MULTILINE, "2D"

        # et c'est parti pour l'optimisation de la mise à plat
 
        for it in 0...iterations
          dif = Maill2D.new(colonnes, lignes) # tableau des déplacements
          for i in 0...colonnes
            for j in 0...lignes
              ### on fait varier x
              #UI.messagebox tab_point2d.points[i][j].to_s, MB_MULTILINE, "2D"
              tab_point2d.points[i][j].x += ecart
              air1 = tab_point2d.aires_point(i,j)
              #UI.messagebox air1.to_s, MB_MULTILINE, "2D"
              long1 = tab_point2d.longueurs_point(i,j)
              #UI.messagebox long1.to_s, MB_MULTILINE, "2D"
              angle1 = tab_point2d.angles_point(i,j)
              #UI.messagebox angle1.to_s, MB_MULTILINE, "2D"
              tab_point2d.points[i][j].x -= 2*ecart
              air2 = tab_point2d.aires_point(i,j)
              long2 = tab_point2d.longueurs_point(i,j)
              angle2 = tab_point2d.angles_point(i,j)
              tab_point2d.points[i][j].x += ecart
              air_dif1 = air_dif2 = long_dif1 = long_dif2 = angle_dif1 = angle_dif2 = 0
              for k in 0...6
                #UI.messagebox "1".to_s, MB_MULTILINE, "2D"
                air_dif1 += ((air1[k]-tab_point3d_aires[i][j][k])/100.0)**2
                air_dif2 += ((air2[k]-tab_point3d_aires[i][j][k])/100.0)**2
                #UI.messagebox "air1 = "+air1[k].to_s+" - air2 = "+air2[k].to_s+"- aire3d = "+tab_point3d_aires[i][j][k].to_s+" - air_dif1 = "+air_dif1.to_s+" - air_dif2 = "+air_dif2.to_s, MB_MULTILINE, "aire"
                if k<4 
                  long_dif1 += (long1[k]-tab_point3d_longueurs[i][j][k])**2
                  long_dif2 += (long2[k]-tab_point3d_longueurs[i][j][k])**2
                  #UI.messagebox "long1 = "+long1[k].to_s+" - long2 = "+long2[k].to_s+"- long3d = "+tab_point3d_longueurs[i][j][k].to_s+" - long_dif1 = "+long_dif1.to_s+" - long_dif2 = "+long_dif2.to_s, MB_MULTILINE, "longueur"
                  angle_dif1 += ((angle1[k]-tab_point3d_angles[i][j][k]).radians)**2
                  angle_dif2 += ((angle2[k]-tab_point3d_angles[i][j][k]).radians)**2
                  #UI.messagebox "angle1 = "+angle1[k].radians.to_s+" - angle2 = "+angle2[k].radians.to_s+"- angle3d = "+tab_point3d_angles[i][j][k].radians.to_s+" - angle_dif1 = "+angle_dif1.to_s+" - angle_dif2 = "+angle_dif2.to_s, MB_MULTILINE, "angle"
                end
              end
              #UI.messagebox "3".to_s, MB_MULTILINE, "2D"
              energie1 = pd_aires*air_dif1 + pd_longu*long_dif1 + pd_angle*angle_dif1
              #UI.messagebox energie1.to_s, MB_MULTILINE, "energie"
              energie2 = pd_aires*air_dif2 + pd_longu*long_dif2 + pd_angle*angle_dif2
              #UI.messagebox energie2.to_s, MB_MULTILINE, "energie2"
              xxx = -((energie1-energie2)/(2*ecart))
              if xxx.abs > 0.5
                xxx = xxx/xxx.abs*0.5 
              end
              #UI.messagebox energie1.to_s+"-"+energie2.to_s+"-"+xxx.to_s, MB_MULTILINE, "xxx"
              ### on fait varier y
              tab_point2d.points[i][j].y += ecart
              air1 = tab_point2d.aires_point(i,j)
              long1 = tab_point2d.longueurs_point(i,j)
              angle1 = tab_point2d.angles_point(i,j)
              tab_point2d.points[i][j].y -= 2*ecart
              air2 = tab_point2d.aires_point(i,j)
              long2 = tab_point2d.longueurs_point(i,j)
              angle2 = tab_point2d.angles_point(i,j)
              tab_point2d.points[i][j].y += ecart
              air_dif1 = air_dif2 = long_dif1 = long_dif2 = angle_dif1 = angle_dif2 = 0
              for k in 0...6
                air_dif1 += ((air1[k]-tab_point3d_aires[i][j][k])/100.0)**2
                air_dif2 += ((air2[k]-tab_point3d_aires[i][j][k])/100.0)**2
                if k<4 
                  long_dif1 += (long1[k]-tab_point3d_longueurs[i][j][k])**2
                  long_dif2 += (long2[k]-tab_point3d_longueurs[i][j][k])**2
                  angle_dif1 += ((angle1[k]-tab_point3d_angles[i][j][k]).radians)**2
                  angle_dif2 += ((angle2[k]-tab_point3d_angles[i][j][k]).radians)**2
                end
              end
              energie1 = pd_aires*air_dif1 + pd_longu*long_dif1 + pd_angle*angle_dif1
              energie2 = pd_aires*air_dif2 + pd_longu*long_dif2 + pd_angle*angle_dif2
              #UI.messagebox "5".to_s, MB_MULTILINE, "2D"
              yyy = -((energie1-energie2)/(2*ecart))
              if yyy.abs > 0.5
                yyy = yyy/yyy.abs*0.5
              end
              #UI.messagebox energie1.to_s+"-"+energie2.to_s+"-"+yyy.to_s, MB_MULTILINE, "xxx"
              dif.points[i][j] = Point2D.new(xxx, yyy)  
              #UI.messagebox "6".to_s, MB_MULTILINE, "2D"
            end
          end
          #UI.messagebox dif.points.to_s, MB_MULTILINE, "2D"
          for i in 0...colonnes
            for j in 0...lignes
              tab_point2d.points[i][j].x += dif.points[i][j].x
              tab_point2d.points[i][j].y += dif.points[i][j].y
            end
          end

        end

        plat_group = groupe_laizes.entities.add_group

        for i in 0...colonnes-1
          for j in 0...lignes-1
            new_vertices = []
            new_vertices << Geom::Point3d.new(tab_point2d.points[i][j].x, tab_point2d.points[i][j].y, 0)
            new_vertices << Geom::Point3d.new(tab_point2d.points[i+1][j].x, tab_point2d.points[i+1][j].y, 0)
            new_vertices << Geom::Point3d.new(tab_point2d.points[i+1][j+1].x, tab_point2d.points[i+1][j+1].y, 0)
            new_vertices << Geom::Point3d.new(tab_point2d.points[i][j+1].x, tab_point2d.points[i][j+1].y, 0)
            plat_face = plat_group.entities.add_face(new_vertices)
            plat_face.material = @tab_laizes[compt][compt2][compt3].material
            plat_face.back_material = @tab_laizes[compt][compt2][compt3].back_material
          end
        end

        #UI.messagebox "11".to_s, MB_MULTILINE, "taille"
        #UI.messagebox "7".to_s, MB_MULTILINE, "taille"
        eloign = 2.0
        vector = Geom::Vector3d.new(eloign * new_group.bounds.center.x, eloign * new_group.bounds.center.y, 0)
        new_group.move!(vector)
        plat_group.move!(vector)
        compt4 += inc
      end
    end

    vector = Geom::Vector3d.new(0, 1*groupe_laizes.bounds.width, 0)
    groupe_laizes.move!(vector)

  end

end


############################################## variables globales ##############################################################################


$membranes	= []
$cur_m = false
$maillage_realise = true


def nouvelle_forme

  #fait le ménage dans les membranes déjà crées si elles sont marquées comme deleted?
  i=$membranes.length-1
  while i>=0
    $membranes.delete_at i if $membranes[i].group.deleted?
    i-=1
  end

  # Create the WebDialog and set its HTML file
  maillage_dialog = UI::HtmlDialog.new(
    {
      :dialog_title => "Paramètres de maillage",
      :preferences_key => "com.sample.plugin",
      :scrollable => true,
      :resizable => true,
      :width => 400,
      :height => 500,
      :left => 400,
      :top => 200,
      :min_width => 50,
      :min_height => 50,
      :max_width =>1000,
      :max_height => 1000,
      :style => UI::HtmlDialog::STYLE_DIALOG
    })
  
  path = Sketchup.find_support_file "ChapAndCo/ChapAndCo_menu_principal.html", "Plugins"
  maillage_dialog.set_file path

  maillage_dialog.add_action_callback("recup_vals") {|d, arg|
    v = arg.to_s.split(",")
    # toil_tour, ht_pot_tour, abside, dec_abside,
    nb_sommets, nb_poteaux, haut_chap, rayon_sommet, oblongue, coup_ob_m, rayon_cercle_sommets, dec, choix_cercle, rayon_chap, petit_rayon_chap, nb_div_noue, nb_div_sabliere = v
    
    ## rajoute une nouvelle membrane à la fin du tableau
    $membranes << Membrane.new
    ## puis crée le maillage
    $cur_m = true

    $membranes.last.maillage(nb_sommets, nb_poteaux, haut_chap, rayon_sommet, oblongue, coup_ob_m, rayon_cercle_sommets, dec, choix_cercle, rayon_chap, petit_rayon_chap, nb_div_noue, nb_div_sabliere)
    maillage_dialog.close
    }
    
  maillage_dialog.show
  
end

def mise_en_tension
  if($cur_m)||($membranes.length == 1)
		$cur_m = false
		$membranes.last.regl
	else
		s = Sketchup.active_model.selection
		if ((s.length != 1) or ($membranes.length == 0))
			UI.beep
			return
		end
    #UI.messagebox $membranes.to_s, MB_MULTILINE, "membrane"
		g = s[0]
		found = -1
		for i in 0..$membranes.length-1
			if($membranes[i].group == g)
				found = i
				break
			end
		end

		if found != -1
			$membranes[found].regl
			$cur_m = false
		else
			UI.messagebox "Mauvaise sélection", MB_OK, "ChapAndCo"
		end

		s.clear
	end
  
end

def laize
  if($cur_m)||($membranes.length == 1)
		$cur_m = false
		$membranes.last.laiz
	else
		s = Sketchup.active_model.selection
		if ((s.length != 1) or ($membranes.length == 0))
			UI.beep
			return
		end
		g = s[0]
		found = -1
		for i in 0..$membranes.length-1
			if($membranes[i].group == g)
				found = i
				break
			end
		end

		if found != -1
			$membranes[found].laiz
			$cur_m = false
		else
			UI.messagebox "Mauvaise sélection", MB_OK, "ChapAndCo"
		end

		s.clear
	end
  
end

def peindre
  if($cur_m)||($membranes.length == 1)
		$cur_m = false
		$membranes.last.peinture
	else
		s = Sketchup.active_model.selection
		if ((s.length != 1) or ($membranes.length == 0))
			UI.beep
			return
		end
		g = s[0]
		found = -1
		for i in 0..$membranes.length-1
			if($membranes[i].group == g)
				found = i
				break
			end
		end

		if found != -1
			$membranes[found].peinture
			$cur_m = false
		else
			UI.messagebox "Mauvaise sélection", MB_OK, "ChapAndCo"
		end

		s.clear
	end
  
end


