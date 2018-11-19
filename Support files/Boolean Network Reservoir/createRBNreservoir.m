function genotype = createRBNreservoir(config) 

genotype = [];
for res = 1:config.popSize    
    
    genotype(res).trainError = 1;    
    genotype(res).valError = 1;  
    genotype(res).testError = 1;
    genotype(res).inputShift = 1;
    genotype(res).inputScaling = 2*rand;
    
    if isempty(config.trainInputSequence)
        genotype(res).nInputUnits = 1;
        genotype(res).nOutputUnits = 1;
        config.task_num_inputs = 1;
        config.task_num_outputs = 1;
    else
        genotype(res).nInputUnits = size(config.trainInputSequence,2);
        genotype(res).nOutputUnits = size(config.trainOutputSequence,2);
        config.task_num_inputs = size(config.trainInputSequence,2);
        config.task_num_outputs =size(config.trainOutputSequence,2);
    end
    
    genotype(res).size = config.maxMinorUnits;
    genotype(res).RBNtype = config.RBNtype;   
    
    if strcmp(config.resType,'basicCA')
        genotype(res).conn= config.conn;
        genotype(res).rules = config.rules;
        genotype(res).node = initNodes(genotype(res).size,config.initialStates,zeros(genotype(res).size,1),zeros(genotype(res).size,1));
    else
        genotype(res).node = initNodes(genotype(res).size);
        genotype(res).conn= initConnections(genotype(res).size, config.k);
        genotype(res).rules = initRules(genotype(res).size, config.k);
    end
    
    genotype(res).node = assocRules(genotype(res).node, genotype(res).rules);
    genotype(res).node = assocNeighbours(genotype(res).node, genotype(res).conn);
    
    genotype(res).nTotalUnits = genotype(res).size;
    genotype(res).leakRate = rand;
    
    genotype(res).dot_perc = rand;
    genotype(res).input_loc = zeros((genotype(res).size),1);
    genotype(res).input_loc(randperm(size(genotype(res).input_loc,1),round(randi([1 round(size(genotype(res).input_loc,1))])*genotype(res).dot_perc))) = 1;
    genotype(res).totalInputs = sum(genotype(res).input_loc);
        
    %inputweights
    if config.sparseInputWeights
        inputWeights = sprand((genotype(res).size),config.task_num_inputs, 0.1); 
        inputWeights(inputWeights ~= 0) = ...
            2*inputWeights(inputWeights ~= 0)  - 1;
        genotype(res).w_in = inputWeights;
    else
        if config.restricedWeight
            for r = 1:config.task_num_inputs
                genotype(res).w_in(:,r) = datasample(0.2:0.2:1,(genotype(res).size));
            end
        else
            genotype(res).w_in = 2*rand((genotype(res).size),config.task_num_inputs)-1;
        end
    end
    
    genotype(res).outputWeights = zeros(genotype(res).size+config.task_num_inputs,config.task_num_outputs);
    
    if config.evolvedOutputStates
        genotype(res).state_perc = 0.1;
        genotype(res).state_loc = zeros(genotype(res).size,1);
        genotype(res).state_loc(randperm(size(genotype(res).state_loc,1),round(randi([1 round(size(genotype(res).state_loc,1))])*genotype(res).state_perc))) = 1;
        genotype(res).totalStates = sum(genotype(res).state_loc);
    end
    
end