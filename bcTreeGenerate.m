function [Tree,biTree,id,block]=bcTreeGenerate(G)
%Tree:IsComponent ComponentIndex CutVertexIndex
[Tree,id]=bctree(G);id=id';
tn=size(Tree.Nodes,1);nc=sum(Tree.Nodes.IsComponent);
Tree.Nodes.TID=[1:tn]';
for i=1:tn
    Tree.Nodes.Size(i,1)=sum(id==i);
    if i>nc
        Tree.Nodes.Cost(i,1)=G.Nodes.Cost(Tree.Nodes.CutVertexIndex(i));
        Tree.Nodes.CutID(i,1)=G.Nodes.ID(Tree.Nodes.CutVertexIndex(i));
  end
end

block=0;
if size(Tree.Nodes,1)==1
    block=1;
    biTree=[];
else
    biTree=Tree;
    biTree.Nodes.IsComponent=[]; 
    biTree.Nodes.ComponentIndex=[];
    biTree.Nodes.CutVertexIndex=[];
    dfs=dfsearch(Tree,1);nt_n=1;
    for i=1:length(dfs)              
        nei=neighbors(Tree,dfs(i));
        a=ismember(nei,dfs(1:i));
        nei(a)=[];
        k=length(nei);
        if k>1
            start=dfs(i);
            for nk=1:k
                if nk==1
                    biTree = rmedge(biTree,dfs(i),nei(nk));
                    biTree= addedge(biTree,[dfs(i) tn+nt_n],[tn+nt_n nei(nk)]);
                    biTree.Nodes.Size(tn+nt_n)=Tree.Nodes.Size(dfs(i));
                    biTree.Nodes.Cost(tn+nt_n)=Tree.Nodes.Cost(dfs(i));
                    biTree.Nodes.CutID(tn+nt_n)=Tree.Nodes.CutID(dfs(i));
                    biTree.Nodes.TID(tn+nt_n)=Tree.Nodes.TID(dfs(i));
                    nt_n=nt_n+1;
                elseif nk>1&&nk<k
                    biTree = rmedge(biTree,dfs(i),nei(nk));   
                    biTree= addedge(biTree,start,tn+nt_n);
                    start=tn+nt_n;
                    biTree= addedge(biTree,[start tn+nt_n+1],[tn+nt_n+1 nei(nk)]);
                    biTree.Nodes.Size(tn+nt_n)=Tree.Nodes.Size(dfs(i));
                    biTree.Nodes.Cost(tn+nt_n)=Tree.Nodes.Cost(dfs(i));
                    biTree.Nodes.CutID(tn+nt_n)=Tree.Nodes.CutID(dfs(i));
                    biTree.Nodes.TID(tn+nt_n)=Tree.Nodes.TID(dfs(i));
                    biTree.Nodes.Size(tn+nt_n+1)=Tree.Nodes.Size(dfs(i));
                    biTree.Nodes.Cost(tn+nt_n+1)=Tree.Nodes.Cost(dfs(i));
                    biTree.Nodes.CutID(tn+nt_n+1)=Tree.Nodes.CutID(dfs(i));
                    biTree.Nodes.TID(tn+nt_n+1)=Tree.Nodes.TID(dfs(i));
                    nt_n=nt_n+2;
                elseif nk==k
                    biTree = rmedge(biTree,dfs(i),nei(nk));   
                    biTree= addedge(biTree,[start tn+nt_n],[tn+nt_n nei(nk)]);
                    biTree.Nodes.Size(tn+nt_n)=Tree.Nodes.Size(dfs(i));
                    biTree.Nodes.Cost(tn+nt_n)=Tree.Nodes.Cost(dfs(i));
                    biTree.Nodes.CutID(tn+nt_n)=Tree.Nodes.CutID(dfs(i));
                    biTree.Nodes.TID(tn+nt_n)=Tree.Nodes.TID(dfs(i));
                    nt_n=nt_n+1;
                end
            end
        end
    end
end