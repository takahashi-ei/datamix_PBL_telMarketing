
# coding: utf-8

# In[24]:


import pandas as pd

df = pd.read_csv('../data/convert_unknown.csv')


# In[25]:


df.head()


# In[26]:


#k-means法を使ってみる
#yの値を削除duration_small_30_df = duration_small_30_df
duration_small_30_df = train_df[train_df['duration'] < 30]
duration_small_30_df = duration_small_30_df.drop(['y_frag'],axis=1)
#標準化前のデータを削除
duration_small_30_df = duration_small_30_df.drop(['age'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['duration'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['campaign'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['pdays'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['previous'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['emp.var.rate'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['cons.price.idx'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['cons.conf.idx'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['euribor3m'],axis=1)
duration_small_30_df = duration_small_30_df.drop(['nr.employed'],axis=1)

#ダミー変数化
duration_small_30_df = pd.get_dummies(data=duration_small_30_df,columns=['job','marital','education','default','housing','loan','contact',                                                'month','day_of_week','poutcome']) 

duration_small_30_df.head()


# # duration 30秒未満のデータをk-meansにかけてみる 

# In[27]:


from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
cluster_number = 15

cluster_sse = []
for i in range(1,cluster_number):
    km = KMeans(n_clusters = i,random_state=1234)
    km.fit(duration_small_30_df)
    cluster_pred = km.predict(duration_small_30_df)
    centers = km.cluster_centers_
    cluster_sse.append(km.inertia_)
    plt.plot(i, km.inertia_)
#    print(str(i) + "," + str(km.inertia_))

plt.plot(range(1,cluster_number),cluster_sse)
plt.xlabel("cluster count")
plt.ylabel("SSE")
plt.savefig('duration_min_30_SSE.png')
plt.show()



# In[28]:


#クラス多数3が最大となっているのでそのときの重心の情報を出力
from statistics import mean, median,variance,stdev

km = KMeans(n_clusters = 3,random_state=1234)
km.fit(duration_small_30_df)
cluster_pred = km.predict(duration_small_30_df)
centers = km.cluster_centers_

#print(km.cluster_centers_)
cluster_df = pd.DataFrame(data=km.cluster_centers_,columns = duration_small_30_df.columns)
cluster_df['age'] = cluster_df['std_age'] *  stdev(train_df['age']) + mean(train_df['age'])
cluster_df['duration'] = cluster_df['std_duration'] *  stdev(train_df['duration']) + mean(train_df['duration'])
cluster_df['campaign'] = cluster_df['std_campaign'] *  stdev(train_df['campaign']) + mean(train_df['campaign'])
cluster_df['pdays'] = cluster_df['std_pdays'] *  stdev(train_df['pdays']) + mean(train_df['pdays'])
cluster_df['previous'] = cluster_df['std_previous'] *  stdev(train_df['previous']) + mean(train_df['previous'])
cluster_df['empVarRate'] = cluster_df['std_empVarRate'] *  stdev(train_df['emp.var.rate']) + mean(train_df['emp.var.rate'])
cluster_df['CPI'] = cluster_df['std_CPI'] *  stdev(train_df['cons.price.idx']) + mean(train_df['cons.price.idx'])
cluster_df['CCI'] = cluster_df['std_CCI'] *  stdev(train_df['cons.conf.idx']) + mean(train_df['cons.conf.idx'])
cluster_df['euribior'] = cluster_df['std_euribior'] *  stdev(train_df['euribor3m']) + mean(train_df['euribor3m'])
cluster_df['employed'] = cluster_df['std_employed'] *  stdev(train_df['nr.employed']) + mean(train_df['nr.employed'])

pd.set_option("display.max_rows", 101)
pd.options.display.precision = 2
cluster_df.T


# In[21]:


print('cluster0:' + str(sum(cluster_pred == 0)))
print('cluster1:' + str(sum(cluster_pred == 1)))
print('cluster2:' + str(sum(cluster_pred == 2)))


# # duration>30でy=noのものをk-meansでかけてみる

# In[29]:


y_no_df = df[(df['duration'] > 30) & (df['y'] == 'no') ]

y_no_df = y_no_df.drop(['y'],axis=1)
y_no_df = y_no_df.drop(['y_frag'],axis=1)
#標準化前のデータを削除
y_no_df = y_no_df.drop(['age'],axis=1)
y_no_df = y_no_df.drop(['duration'],axis=1)
y_no_df = y_no_df.drop(['campaign'],axis=1)
y_no_df = y_no_df.drop(['pdays'],axis=1)
y_no_df = y_no_df.drop(['previous'],axis=1)
y_no_df = y_no_df.drop(['emp.var.rate'],axis=1)
y_no_df = y_no_df.drop(['cons.price.idx'],axis=1)
y_no_df = y_no_df.drop(['cons.conf.idx'],axis=1)
y_no_df = y_no_df.drop(['euribor3m'],axis=1)
y_no_df = y_no_df.drop(['nr.employed'],axis=1)

#ダミー変数化
y_no_df = pd.get_dummies(data=y_no_df,columns=['job','marital','education','default','housing','loan','contact',                                                'month','day_of_week','poutcome']) 

y_no_df.head()
y_no_df


# In[30]:


from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
cluster_number = 15

cluster_sse = []
for i in range(1,cluster_number):
    km = KMeans(n_clusters = i,random_state=1234)
    km.fit(y_no_df)
    cluster_pred = km.predict(y_no_df)
    centers = km.cluster_centers_
    cluster_sse.append(km.inertia_)
    plt.plot(i, km.inertia_)
#    print(str(i) + "," + str(km.inertia_))

plt.plot(range(1,cluster_number),cluster_sse)
plt.xlabel("cluster count")
plt.ylabel("SSE")
plt.savefig('duration_more_30_SSE.png')
plt.show()


# In[32]:


#クラス多数3が最大となっているのでそのときの重心の情報を出力
from statistics import mean, median,variance,stdev

km = KMeans(n_clusters = 3,random_state=1234)
km.fit(y_no_df)
cluster_pred = km.predict(y_no_df)
centers = km.cluster_centers_

#print(km.cluster_centers_)
cluster_df = pd.DataFrame(data=km.cluster_centers_,columns = y_no_df.columns)
cluster_df['age'] = cluster_df['std_age'] *  stdev(train_df['age']) + mean(train_df['age'])
cluster_df['duration'] = cluster_df['std_duration'] *  stdev(train_df['duration']) + mean(train_df['duration'])
cluster_df['campaign'] = cluster_df['std_campaign'] *  stdev(train_df['campaign']) + mean(train_df['campaign'])
cluster_df['pdays'] = cluster_df['std_pdays'] *  stdev(train_df['pdays']) + mean(train_df['pdays'])
cluster_df['previous'] = cluster_df['std_previous'] *  stdev(train_df['previous']) + mean(train_df['previous'])
cluster_df['empVarRate'] = cluster_df['std_empVarRate'] *  stdev(train_df['emp.var.rate']) + mean(train_df['emp.var.rate'])
cluster_df['CPI'] = cluster_df['std_CPI'] *  stdev(train_df['cons.price.idx']) + mean(train_df['cons.price.idx'])
cluster_df['CCI'] = cluster_df['std_CCI'] *  stdev(train_df['cons.conf.idx']) + mean(train_df['cons.conf.idx'])
cluster_df['euribior'] = cluster_df['std_euribior'] *  stdev(train_df['euribor3m']) + mean(train_df['euribor3m'])
cluster_df['employed'] = cluster_df['std_employed'] *  stdev(train_df['nr.employed']) + mean(train_df['nr.employed'])

pd.set_option("display.max_rows", 101)
pd.options.display.precision = 2
cluster_df.T
cluster_df.to_csv("duration_30.csv")


# In[10]:


import numpy as np
from sklearn.decomposition import PCA

pca = PCA(n_components=20)
pca.fit(duration_small_30_df)

x = ['PC%02s' %i for i in range(1, len(pca.explained_variance_ratio_)+1)]
y = pca.explained_variance_ratio_
cum_y = np.cumsum(y)
plt.figure(figsize=(10,5))
plt.bar(x, y, align="center", color="blue")
plt.plot(x, cum_y, color="magenta", marker="o")
for i, j in zip(x, y):
    plt.text(i, j, '%.2f' % j, ha='center', va='bottom', fontsize=12)
plt.ylim([0,1])
plt.ylabel('Percentage of variance explained', fontsize = 14)
plt.tick_params(labelsize = 14)
plt.tight_layout()
plt.grid()
plt.show()


# In[11]:


from sklearn.decomposition import PCA

# n_components で削減後の次元数を指定します
X_reduced = PCA(n_components=1, random_state=1234).fit_transform(duration_small_30_df)
X_reduced
cluster_number = 15

cluster_sse = []
for i in range(1,cluster_number):
    km = KMeans(n_clusters = i,random_state=1234)
    km.fit(X_reduced)
    cluster_pred = km.predict(X_reduced)
    centers = km.cluster_centers_
    cluster_sse.append(km.inertia_)
    plt.plot(i, km.inertia_)
    print(str(i) + "," + str(km.inertia_))

plt.plot(range(1,cluster_number),cluster_sse)
plt.xlabel("cluster count")
plt.ylabel("SSE")
plt.show()


# In[12]:


import matplotlib.pyplot as plt
cluster_number = 15

cluster_sse = []
for i in range(1,cluster_number):
    km = KMeans(n_clusters = i,random_state=1234)
    km.fit(train_df)
    cluster_pred = km.predict(train_df_sc)
    centers = km.cluster_centers_
    cluster_sse.append(km.inertia_)
    plt.plot(i, km.inertia_)


plt.plot(range(1,cluster_number),cluster_sse)
plt.xlabel("cluster count")
plt.ylabel("SSE")
plt.show()

