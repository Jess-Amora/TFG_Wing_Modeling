function aircraft = createAircraft(name, MTOW, wingSpan, wingArea, sweep, taperRatio, structParams)
    % Create a structured database entry for a given aircraft
    
    aircraft.Name = name;
    aircraft.Weights.MTOW = MTOW;
    aircraft.Geometry.WingSpan = wingSpan;
    aircraft.Geometry.WingArea = wingArea;
    aircraft.Geometry.Sweep = sweep;
    aircraft.Geometry.TaperRatio = taperRatio;
    
    % Structural parameters
    aircraft.Structure.RibSpacing = structParams.RibSpacing;
    aircraft.Structure.StringerSpacing = structParams.StringerSpacing;
    aircraft.Structure.SparLocations = structParams.SparLocations;
end
