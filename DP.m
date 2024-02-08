function table_list= DP(Tree,k)   %% Depth-First-Search
N=size(Tree.Nodes,1);
table_list=cell(N,1);
ta=table([],{},{},[],[],{},'VariableNames',{'t','S0','S1','L1','Z','RemovalNodes'});
dfs=dfsearch(Tree,1);
for p=1:N
    nei=neighbors(Tree,dfs(p));
    if length(nei)==1&&p~=1
        Tree.Nodes.type(dfs(p))=1;
    elseif length(nei)>2&&p~=1
        Tree.Nodes.type(dfs(p))=2;
    elseif length(nei)==2&&p~=1
        Tree.Nodes.type(dfs(p))=3;
    elseif length(nei)==1&&p==1
        Tree.Nodes.type(dfs(p))=3;
    elseif length(nei)>1&&p==1
        Tree.Nodes.type(dfs(p))=2;
    end
    if p==1
        Tree.Nodes.parent(p)=0;
    else
        a=ismember(dfs(1:p),nei);
        Tree.Nodes.parent(dfs(p))=dfs(a);
    end
end
for q=N:-1:1
    i=dfs(q);
    if Tree.Nodes.type(i)==1
        if Tree.Nodes.CutID(i)~=0
            table_list{i}=ta;
            table_list{i}.t(1)=Tree.Nodes.TID(i);
            table_list{i}.S1{1}=Tree.Nodes.TID(i);
            table_list{i}.L1(1)=Tree.Nodes.Size(i);
            table_list{i}.Z(1)=0;

            table_list{i}.t(2)=Tree.Nodes.TID(i);
            table_list{i}.S0{2}= Tree.Nodes.TID(i);
            table_list{i}.L1(2)=0;
            table_list{i}.Z(2)=Tree.Nodes.Cost(i);
            table_list{i}.RemovalNodes{2}=Tree.Nodes.CutID(i);
        else
            table_list{i}=ta;
            table_list{i}.t(1)=Tree.Nodes.TID(i);
            table_list{i}.S1{1}=Tree.Nodes.TID(i);
            table_list{i}.L1(1)=Tree.Nodes.Size(i);
            table_list{i}.Z(1)=0;
        end
    elseif Tree.Nodes.type(i)==2
        table_list{i}=ta;
        tv=Tree.Nodes.parent==i;
        child=find(tv);
        count=1;
        for j=1:size(table_list{child(1)},1)
            for m=1:size(table_list{child(2)},1)
                if isequal(table_list{child(1)}.S0{j},table_list{child(2)}.S0{m})
                    if isempty(table_list{child(1)}.S0{j})
                        l1=table_list{child(1)}.L1(j)+table_list{child(2)}.L1(m)-Tree.Nodes.Size(i);
                    else 
                        l1=table_list{child(1)}.L1(j)+table_list{child(2)}.L1(m);
                    end
                    if l1<=k
                        if isempty(table_list{child(1)}.S0{j})
                                Z=table_list{child(1)}.Z(j)+table_list{child(2)}.Z(m);
                            else
                                Z=table_list{child(1)}.Z(j)+table_list{child(2)}.Z(m)-Tree.Nodes.Cost(i);
                        end
                        
                        if count>1
                            delete=find(table_list{i}.L1(1:(count-1))==l1);
                            if isempty(delete)
                                table_list{i}.t(count)=table_list{child(1)}.t(j);
                                table_list{i}.S0{count}=table_list{child(1)}.S0{j};
                                table_list{i}.S1{count}=table_list{child(1)}.S1{j};
                                table_list{i}.L1(count)=l1;
                                table_list{i}.Z(count)=Z;
                                table_list{i}.RemovalNodes{count}=unique([table_list{child(1)}.RemovalNodes{j},table_list{child(2)}.RemovalNodes{m}]);
                                count=count+1;
                            elseif Z<table_list{i}.Z(delete)
                                table_list{i}.t(delete)=table_list{child(1)}.t(j);
                                table_list{i}.S0{delete}=table_list{child(1)}.S0{j};
                                table_list{i}.S1{delete}=table_list{child(1)}.S1{j};
                                table_list{i}.L1(delete)=l1;
                                table_list{i}.Z(delete)=Z;
                                table_list{i}.RemovalNodes{delete}=unique([table_list{child(1)}.RemovalNodes{j},table_list{child(2)}.RemovalNodes{m}]);
                            end
                            
                        else                            
                            table_list{i}.t(count)=table_list{child(1)}.t(j);
                            table_list{i}.S0{count}=table_list{child(1)}.S0{j};
                            table_list{i}.S1{count}=table_list{child(1)}.S1{j};
                            table_list{i}.L1(count)=l1;
                            table_list{i}.Z(count)=Z;                            
                            table_list{i}.RemovalNodes{count}=unique([table_list{child(1)}.RemovalNodes{j},table_list{child(2)}.RemovalNodes{m}]);
                            count=count+1;
                        end                    
                    end
                end
                
            end
        end
             
    elseif Tree.Nodes.type(i)==3
        table_list{i}=ta;
        tv=Tree.Nodes.parent==i;
        le=size(table_list{tv},1);
        count=1;
        for j=1:le           
            l1=table_list{tv}.L1(j)+Tree.Nodes.Size(i);
            if Tree.Nodes.CutID(i)~=0
                if l1<=k
                    table_list{i}.t(count)=Tree.Nodes.TID(i);
                    table_list{i}.S1{count}=Tree.Nodes.TID(i);
                    table_list{i}.L1(count)=l1;
                    table_list{i}.Z(count)=table_list{tv}.Z(j);
                    table_list{i}.RemovalNodes{count}=table_list{tv}.RemovalNodes{j};
                    count=count+1;
                end
                table_list{i}.t(count)=Tree.Nodes.TID(i);
                table_list{i}.S0{count}= Tree.Nodes.TID(i);
                table_list{i}.L1(count)=0;
                table_list{i}.Z(count)=table_list{tv}.Z(j)+Tree.Nodes.Cost(i);
                table_list{i}.RemovalNodes{count}=unique([table_list{tv}.RemovalNodes{j},Tree.Nodes.CutID(i)]);
                
                count=count+1;
                if count-1>1
                    
                    deleteID=[];
                    for n=1:count-2
                        if isequal(table_list{i}.S0{count-1},table_list{i}.S0{n})&&isequal(table_list{i}.L1(count-1),table_list{i}.L1(n))
                            if table_list{i}.Z(count-1)>=table_list{i}.Z(n)
                                deleteID=[deleteID count-1];
                            else
                                deleteID=[deleteID n];
                            end
                        end
                    end
                    deleteID=unique(deleteID);
                    table_list{i}(deleteID,:)=[];
                    count=count-length(deleteID);
                end
            else
                if l1<=k
                    table_list{i}.t(count)=Tree.Nodes.TID(i);
                    table_list{i}.S1{count}=Tree.Nodes.TID(i);
                    table_list{i}.L1(count)=l1;
                    table_list{i}.Z(count)=table_list{tv}.Z(j);
                    table_list{i}.RemovalNodes{count}=table_list{tv}.RemovalNodes{j};
                    count=count+1;
                    if count-1>1
                        deleteID=[];
                        for n=1:count-2
                            if isequal(table_list{i}.S0{count-1},table_list{i}.S0{n})&&isequal(table_list{i}.L1(count-1),table_list{i}.L1(n))
                                if table_list{i}.Z(count-1)>=table_list{i}.Z(n)
                                    deleteID=[deleteID count-1];
                                else
                                    deleteID=[deleteID n];
                                end
                            end
                        end
                        deleteID=unique(deleteID);
                        table_list{i}(deleteID,:)=[];
                        count=count-length(deleteID);
                    end
                end
            end
            
        end
        
        
    end
end