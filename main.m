clc,clear
%%================Simulation of DPA Algorithm=========================

%% data-in & initialize
data=load ('...\datasets\Dbpedia.txt');          % input format of each line: id1 id2

G=graph(data(:,1),data(:,2));                    % object: graph
G=simplify(G);                                   % reduce to simple graph 
N=size(G.Nodes,1);M=size(G.Edges,1);             % N: number of nodes; M: number of edges
G.Nodes.Cost=degree(G);                          % default removal costs: degrees
G.Nodes.ID=[1:N]';                               % Node Index of the original network
C=max(1,floor(0.01*N));                          % threshold constant: default value can be 0.01*N or 1

%% deal with the maximal block by CycleRatio 
data=G;
p=1;
bincell = biconncomp(data, 'OutputForm', 'cell');
blocksize=max(cellfun(@length,bincell));
RemovalCost=0;
while blocksize>C
    c=find(cellfun(@length,bincell)>C,1);
    block=subgraph(data,bincell{c});
    fp=fopen('...\block.txt','a');
    for i=1:size(block.Edges,1)
        for j=1:2
            if j==2
                fprintf(fp,'%g\n',int64(block.Edges.EndNodes(i,j)-1));
            else
                fprintf(fp,'%g\t',int64(block.Edges.EndNodes(i,j)-1));
            end
        end
    end
    fclose(fp);
    command='python CycleRatio_by_Fan.py';
    status=system(command);
    blockCycleRatio= load('CycleRatio.txt');
    blockCycleRatio(:,3)=block.Nodes.ID(blockCycleRatio(:,1)+1);
    node{p,1}=blockCycleRatio(1,3);
    data=rmnode(data,find(data.Nodes.ID==node{p}));
    bincell = biconncomp(data, 'OutputForm', 'cell');
    blocksize=max(cellfun(@length,bincell));
    [~,binsize]=conncomp(data,'OutputForm','cell');
    RemovalCost=RemovalCost+sum(G.Nodes.Cost(node{p}))./(2*M);
    p=p+1;
    delete 'block.txt';
    delete 'CycleRatio.txt';
end

%% Total number of removal nodes by Phase I
filename=['...\RemovalResult.txt'];
fp=fopen(filename,'a');
line1=char('The number of removal nodes by Phase I: ');
fprintf(fp,'%s%g\n',line1,p-1);
fclose(fp);

%% Dynamic Programming Dismantling Process
[bins,binsize]=conncomp(data,'OutputForm','cell');
size=binsize;
for q=1:length(bins)
    if binsize(q)>C
       subg_conn=subgraph(data,bins{q});
       [Tree,biTree,~,block]=bcTreeGenerate(subg_conn);
       table_list= DP(biTree,C);
       op=find(table_list{1}.Z==min(table_list{1}.Z),1);
       node{p,1}=table_list{1}.RemovalNodes{op};
       RemovalCost=RemovalCost+sum(G.Nodes.Cost(node{p}))./(2*M);
       subg_conn=rmnode(subg_conn,find(ismember(subg_conn.Nodes.ID,node{p}')==1));
       [~,subgsize]=conncomp(subg_conn,'OutputForm','cell');
       size(q)=max(subgsize);      
       p=p+1;       
   end
end

%% Output
fp=fopen('...\RemovalResult.txt','a');
line2=char('Overall Removal Cost: ');
fprintf(fp,'%s%g\n',line1,RemovalCost);
line3=char('Removal Nodes: ');
fprintf(fp,'%s\n',line3);
for i=1:p-1
    for j=1:length(node{i})
        if j==length(node{i})
            fprintf(fp,'%g\n',node{i}(j));
        else
            fprintf(fp,'%g\t',node{i}(j));
        end
    end
end
fclose(fp);