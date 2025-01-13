function [config] = configStructF(type,order,d,resolution,timeStep,algorithm,vecMethod,scanWin,itpMethod,GPU)
    
    field_1 = 'type';
    value_1 = type;

    field_2 = 'order';
    value_2 = order;

    field_3 = 'd';
    value_3 = d;

    field_4 = 'resolution';
    value_4 = resolution;

    field_5 = 'timeStep';
    value_5 = timeStep;

    field_6 = 'algorithm';
    value_6 = algorithm;

    field_7 = 'vecMethod';
    value_7 = vecMethod;
    
    field_8 = 'scanWin';
    value_8 = scanWin;
    
    field_9 = 'itpMethod';
    value_9 = itpMethod;
    
    field_10 = 'GPU';
    value_10 = GPU;

    config = struct( ...,
        field_1, value_1, ...,
        field_2, value_2, ...,
        field_3, value_3, ...,
        field_4, value_4, ...,
        field_5, value_5, ...,
        field_6, value_6, ...,
        field_7, value_7, ...,
        field_8, value_8, ...,
        field_9, value_9, ...,
        field_10, value_10 ...,
    );
    
end