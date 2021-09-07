
    function angle = angle_between_atan2(v1,v2)
        
        angle = atan2(norm(det([v2;v1])),dot(v1,v2));
    end
        