#ifndef __COMP_PERSISTENCE_H__
#define __COMP_PERSISTENCE_H__

#include <vector>
#include <algorithm>

using namespace std;

struct vertex {
  unsigned int index;
  double value;
};

struct by_value {
  bool operator()(vertex const &a, vertex const &b) { 
        return a.value > b.value;
    }  
};

int find_top(int id, vector<int> &parents) {
    if(parents[id] != id) {
        parents[id] = find_top(parents[id], parents);
    }
    return parents[id];
}

void compute_persistence(vector<vector<unsigned int> > edges,
                         vector<double> f,
                         vector<pair<unsigned int, double > >& peaks) {
    vector<int > parents(f.size());
    vector<double > deaths(f.size());
    
    vector<vertex > verts(f.size());
    for (int i = 0; i < f.size(); i++) {
        verts[i].index = i;
        verts[i].value = f[i];
        
        parents[i] = -1;
        deaths[i] = -1;
    }
    
    sort(verts.begin(), verts.end(), by_value());

    for (int i = 0; i < f.size(); i++) {
        int id = verts[i].index;
        double value = verts[i].value;
                
        int max_neigh = id;
        vector<int> up_neighs(1,id);
        
        for (int j = 0; j < edges[id].size(); j++) {
            int id2 = edges[id][j];
            
            if(parents[id2] >= 0) {
                int top_parent = find_top(id2, parents);
                up_neighs.push_back(top_parent);
                
                if(f[top_parent] > f[max_neigh]) {
                    max_neigh = top_parent;
                }
            }
        }
        
        for (int j = 0 ; j < up_neighs.size() ; j++) {
            parents[up_neighs[j]] = max_neigh;
            
            deaths[up_neighs[j]] = value;
        }
    }
    
    for (int i = 0; i < f.size(); i++) {
        // This vertex didn't die immediately after being born, so it was 
        // a local maximum at some point.
        if(deaths[i] != f[i]) {
            double persistence = f[i] - deaths[i];
           
            peaks.push_back(pair<unsigned int, double> (i+1, persistence));
        }
    }   
}


#endif //__COMP_PERSISTENCE_H__
