## Basic Step Statistics Project Based Learning
## Bank Marketing

###
###expect_unknown:unknownのカテゴリーを出現頻度から予測する。
###引数
###  category_list:カテゴリー名の一覧リスト
###  parcentages:各カテゴリーの出現頻度（合計100%となるようにする）
expect_unknown <- function(list,category_list,parcentages){
  exp_list = c()
  t = 0
  for (l in list){
    if (l != "unknown"){
      exp_list = c(exp_list,l)
#      print(paste("[expect_unknown]","non expect:",exp_list[length(exp_list) - 1]))
    }else{
      rnd = as.integer(runif(1,0,100))
      category_index = 1
      for(p in parcentages){
        rnd = rnd - p
        if(rnd <= 0){
          break
        }
        category_index = category_index + 1
        #合計が100%出ない場合この場所を通る。このときはカテゴリーの末尾を入れるようにする
        if (category_index > length(category_list)){
          t = t + 1
#          print(paste("[expect_unknown]","rnd > sum(percentages)!"))
          category_index = length(category_index)
        }
      }
      exp_list = c(exp_list,as.character(category_list[category_index]))
#      print(paste("[expect_unknown]","rnd > sum(percentages) count",as.character(t)))
#      print(paste("[expect_unknown]","expect:",exp_list[length(exp_list)]))
    }
  }
  return(exp_list)
}

###
###expect_job:説明変数jobについて、未定義unknownの処理をする関数
#expect_job <- function(train_data,insert_data){
#  jobs = unique(train_data$job)
#  unknown_data = subset(train_data,job == "unknown")
#  jobs = jobs[-which(jobs %in% "unknown")]
#  percentages = c()
  ##jobには、admin,blue-collar,entrepreneur,housemaid,management,retired,self-employed,service,student,technician,
  ##unemployedのパターンがあるので、それの出現確率を求める。そしてunknownからその出現確率に合うよう抽出する
#  for (j in jobs){
#    per = length(subset(train_data,job==j)$job) / (length(train_data$job) - length(subset(train_data,job=="unknown")$job))
#    percentages = c(percentages,per * 100)
#  }
#  return(expect_unknown(insert_data$job,jobs,percentages))
#}

###
###expect_variable:説明変数について、未定義unknownの処理をする関数。
###                unknownは学習用データの各カテゴリーの分布をみてそれと同じ分布になるよう、
###                test_variableのunknownを分類する。（ただし、）
###引数
####train_variable:学習用のデータ。unknownを含んでいても問題なし
####test_variable:変換するデータ。unknownを含んでいても問題なし
expect_variable <- function(train_variables,test_variables){
  categories = unique(train_variables)
#  unknown_data = train_variables[train_variables == "unknown"]
  categories = categories[-which(categories %in% "unknown")]
  percentages = c()
  ##jobには、admin,blue-collar,entrepreneur,housemaid,management,retired,self-employed,service,student,technician,
  ##unemployedのパターンがあるので、それの出現確率を求める。そしてunknownからその出現確率に合うよう抽出する
  for (c in categories){
    per = length(train_variables[train_variables == c]) / (length(train_variables) - length(train_variables[train_variables == "unknown"]))
    percentages = c(percentages,per * 100)
  }
  return(expect_unknown(test_variables,categories,percentages))
}

##cutoffの値を算出するための関数
##(カットオフ率を変更させてROIを最大化するカットオフ値を求める)
##未実装：過学習を避けるため、クラスバリデーションを行いcutoffの値はその平均値を使う
##引数
## df:テストデータ(正解データyを含む)
## y_pred_per:ロジスティック回帰の予測値
calc_cutoff <-function(df,ypred_per){
  max_value = -1
  max_cutoff = -1
  X = c()
  Y = c()
  #cutoffの値は、0~100まで5刻みで使う
  for (i in 10:100){
    if (i %% 5 != 0){
      next
    }
    cutoff = i / 100
    pred = ifelse(ypred_per > cutoff,1,0) 
    conf_mat<-table(df$y_frag, pred)
    value = conf_mat[4] * 2000 - (conf_mat[3]+conf_mat[4]) * 500
#    value = conf_mat[4] / (conf_mat[2]+conf_mat[4])
    X = c(X,cutoff)
    Y = c(Y,value)
    print(paste("cutoff:",cutoff))
    print(conf_mat)
    print(paste("conf_mat[1]:",conf_mat[1]))
    print(paste("conf_mat[2]:",conf_mat[2]))
    print(paste("conf_mat[3]:",conf_mat[3]))
    print(paste("conf_mat[4]:",conf_mat[4]))
    print(value)
    if (max_value < value){
      max_value = value
      max_cutoff = cutoff
    }
  }
  print(paste('cutoff:',max_cutoff,',value:',max_value))
  plot(X,Y)
  return(max_cutoff)
}

###データ解析用に描画ソフトを起動する
### dfにはロジスティック回帰の結果を
analyze_data<- function(df,glm){
#  install.packages('esquisse')
  df$y_pred<-predict(glm, newdata = df, type="response")
  df$y_line<-predict(glm, newdata = df, type="link")
  esquisse::esquisser(df)
}

# 出力したCSVデータを読み込めます
bank_marketing_train <- read.csv("../data/bank_marketing_train.csv")

#jobのデータ構造を見る->空のデータはなし、unknownが288個。
summary(bank_marketing_train$job)
sum(is.na(bank_marketing_train$job))
sum(is.null(bank_marketing_train$job))
##unknownのjobは、他のjobのカテゴリーに変更する
##jobを推定できるような説明変数がないので、jobの"unknown"以外のカテゴリーの頻度を使う
##（jobの"unknown"以外のカテゴリーの出現頻度と同じになるようにする）
#summary(bank_marketing_train$job)
bank_marketing_train$job = expect_variable(bank_marketing_train$job,bank_marketing_train$job)
bank_marketing_train$job = as.factor(bank_marketing_train$job)
#summary(bank_marketing_train$job)


#Ageのデータを見る。空のデータはなし。
sum(is.na(bank_marketing_train$age))
sum(is.null(bank_marketing_train$age))
hist(bank_marketing_train$age)

#Materialのデータを見る。空のデータはなし。unknownは72個。
sum(is.na(bank_marketing_train$marital))
sum(is.null(bank_marketing_train$marital))
summary(bank_marketing_train$marital)
#bank_marketing_train$job = expect_job(bank_marketing_train,bank_marketing_train)
bank_marketing_train$marital = expect_variable(bank_marketing_train$marital,bank_marketing_train$marital)
bank_marketing_train$marital = as.factor(bank_marketing_train$marital)
summary(bank_marketing_train$marital)

#educationのデータを見る。unknownは1435個
sum(is.na(bank_marketing_train$education))
sum(is.null(bank_marketing_train$education))
summary(bank_marketing_train$education)
bank_marketing_train$education = expect_variable(bank_marketing_train$education,bank_marketing_train$education)
bank_marketing_train$education = as.factor(bank_marketing_train$education)
summary(bank_marketing_train$education)

#defaultのデータを見る。空データはなし。unknownは1435個。yesは3個
sum(is.na(bank_marketing_train$default))
sum(is.null(bank_marketing_train$default))
summary(bank_marketing_train$default)
bank_marketing_train$default = expect_variable(bank_marketing_train$default,bank_marketing_train$default)
bank_marketing_train$default = as.factor(bank_marketing_train$default)
summary(bank_marketing_train$default)

#housingのデータを見る。空データはなし。unknownは885個。
sum(is.na(bank_marketing_train$housing))
sum(is.null(bank_marketing_train$housing))
summary(bank_marketing_train$housing)
bank_marketing_train$housing = expect_variable(bank_marketing_train$housing,bank_marketing_train$housing)
bank_marketing_train$housing = as.factor(bank_marketing_train$housing)
summary(bank_marketing_train$housing)

#loanのデータを見る。空データはなし。unknownは885個。
sum(is.na(bank_marketing_train$loan))
sum(is.null(bank_marketing_train$loan))
summary(bank_marketing_train$loan)
bank_marketing_train$loan = expect_variable(bank_marketing_train$loan,bank_marketing_train$loan)
bank_marketing_train$loan = as.factor(bank_marketing_train$loan)
summary(bank_marketing_train$loan)

#contactのデータを見る。空データはなし。unknownもなし
sum(is.na(bank_marketing_train$contact))
sum(is.null(bank_marketing_train$contact))
summary(bank_marketing_train$contact)

#monthのデータを見る。空データはなし。unknownもなし
#月ごとに電話している人数にかなりの差がある。4月：3876人に対し12月は10人
sum(is.na(bank_marketing_train$month))
sum(is.null(bank_marketing_train$month))
summary(bank_marketing_train$month)

#day_of_weekのデータを見る。空データはなし。unknownもなし
sum(is.na(bank_marketing_train$day_of_week))
sum(is.null(bank_marketing_train$day_of_week))
summary(bank_marketing_train$day_of_week)

#durationのデータを見る。空のデータはなし
sum(is.na(bank_marketing_train$duration))
sum(is.null(bank_marketing_train$duration))
summary(bank_marketing_train$duration)

#campaignのデータを見る。空のデータはなし
sum(is.na(bank_marketing_train$campaign))
sum(is.null(bank_marketing_train$campaign))
summary(bank_marketing_train$campaign)

#pdaysのデータを見る。空のデータはなし
sum(is.na(bank_marketing_train$pdays))
sum(is.null(bank_marketing_train$pdays))
summary(bank_marketing_train$pdays)

#priviousのデータを見る。空のデータはなし
sum(is.na(bank_marketing_train$previous))
sum(is.null(bank_marketing_train$previous))
summary(bank_marketing_train$previous)

#poutcomeのデータを見る。空のデータはなし。unknownもなし
sum(is.na(bank_marketing_train$poutcome))
sum(is.null(bank_marketing_train$poutcome))
summary(bank_marketing_train$poutcome)


#標準化
bank_marketing_train$std_age = (bank_marketing_train$age - mean(bank_marketing_train$age)) / sd(bank_marketing_train$age)
bank_marketing_train$std_duration = (bank_marketing_train$duration - mean(bank_marketing_train$duration)) / sd(bank_marketing_train$duration)
bank_marketing_train$std_campaign = (bank_marketing_train$campaign - mean(bank_marketing_train$campaign)) / sd(bank_marketing_train$campaign)
bank_marketing_train$std_pdays = (bank_marketing_train$pdays - mean(bank_marketing_train$pdays)) / sd(bank_marketing_train$pdays)
bank_marketing_train$std_previous = (bank_marketing_train$previous - mean(bank_marketing_train$previous)) / sd(bank_marketing_train$previous)
bank_marketing_train$std_empVarRate = (bank_marketing_train$emp.var.rate - mean(bank_marketing_train$emp.var.rate)) / sd(bank_marketing_train$emp.var.rate)
bank_marketing_train$std_CPI = (bank_marketing_train$cons.price.idx - mean(bank_marketing_train$cons.price.idx)) / sd(bank_marketing_train$cons.price.idx)
bank_marketing_train$std_CCI = (bank_marketing_train$cons.conf.idx - mean(bank_marketing_train$cons.conf.idx)) / sd(bank_marketing_train$cons.conf.idx)
bank_marketing_train$std_euribior = (bank_marketing_train$euribor3m - mean(bank_marketing_train$euribor3m)) / sd(bank_marketing_train$euribor3m)
bank_marketing_train$std_employed = (bank_marketing_train$nr.employed - mean(bank_marketing_train$nr.employed)) / sd(bank_marketing_train$nr.employed)


#職業で重みを変える
#bank_marketing_train$std_CCI = ifelse(bank_marketing_train$job == 'blue-collar' |  
#                                      bank_marketing_train$job == 'housemaid' | 
#                                        bank_marketing_train$job == 'technician' |
#                                        bank_marketing_train$job == 'student',
#                                      bank_marketing_train$std_CCI * 0.5,bank_marketing_train$std_CCI)
#bank_marketing_train$std_empVarRate = ifelse(bank_marketing_train$job == 'blue-collar' |
#                                            bank_marketing_train$job == 'services' ,
#                                      bank_marketing_train$std_empVarRate * 0.5,bank_marketing_train$std_empVarRate)
#bank_marketing_train$std_euribior = ifelse(bank_marketing_train$job == 'blue-collar' |
#                                          bank_marketing_train$job == 'services' |
#                                          bank_marketing_train$job == 'technician' |
#                                          bank_marketing_train$job == 'entrepreneur' |
#                                          bank_marketing_train$job == 'housemaid' |
#                                          bank_marketing_train$job == 'management' |
#                                          bank_marketing_train$job == 'student',
#                                      bank_marketing_train$std_euribior * 0.5,bank_marketing_train$std_euribior)


bank_marketing_train$std_empVarRate = (mean(subset(bank_marketing_train,y == 'no')$std_empVarRate) - 
                                      mean(subset(bank_marketing_train,y == 'yes')$std_empVarRate)) * 
                                      bank_marketing_train$std_empVarRate
bank_marketing_train$std_empVarRate = ifelse(bank_marketing_train$job == 'student',2,bank_marketing_train$std_empVarRate)

bank_marketing_train$std_CCI = (mean(subset(bank_marketing_train,y == 'no')$std_CCI) - 
                                      mean(subset(bank_marketing_train,y == 'yes')$std_CCI)) * 
                                      bank_marketing_train$std_CCI

bank_marketing_train$std_CPI = (mean(subset(bank_marketing_train,y == 'no')$std_CPI) - 
                                      mean(subset(bank_marketing_train,y == 'yes')$std_CPI)) * 
                                      bank_marketing_train$std_CPI

bank_marketing_train$std_euribior = (mean(subset(bank_marketing_train,y == 'no')$std_euribior) - 
                                      mean(subset(bank_marketing_train,y == 'yes')$std_euribior)) * 
                                      bank_marketing_train$std_euribior
#yをyes=1,no=0に変更
bank_marketing_train$y_frag = ifelse(bank_marketing_train$y == 'yes',1,0)
# duration 30秒未満をリストデータに追加
bank_marketing_train$duration_min_30 = ifelse(bank_marketing_train$duration < 30,1,0)
bank_marketing_train$duration_min_30 = as.factor(bank_marketing_train$duration_min_30)
bank_marketing_train$ressession = ifelse(bank_marketing_train$std_empVarRate < 0,1,0)
bank_marketing_train$ressession = ifelse(bank_marketing_train$std_CPI < 0,1+bank_marketing_train$ressession,0+bank_marketing_train$ressession)
bank_marketing_train$ressession = ifelse(bank_marketing_train$std_CCI < 0,1+bank_marketing_train$ressession,0+bank_marketing_train$ressession)
#ressessionは2のデータが少ないため、2のときのsuccessとなる確率が3となる確率より高くなるので、2以上は共通とする
bank_marketing_train$ressession = ifelse(bank_marketing_train$ressession >= 2,2,bank_marketing_train$ressession)
#bank_marketing_train$ressession = (bank_marketing_train$ressession - mean(bank_marketing_train$ressession)) / sd(bank_marketing_train$ressession)

try_glm = glm(y_frag~.-age-duration-campaign-pdays-previous-emp.var.rate-cons.price.idx-cons.conf.idx-euribor3m-nr.employed-y-y_frag-month-std_employed-day_of_week,data=bank_marketing_train)
step(try_glm)
summary(try_glm)
print(exp(try_glm$coefficients))
library(pscl)
pR2(try_glm)

ypred_per<-predict(try_glm, newdata = bank_marketing_train, type="response")
print(calc_cutoff(bank_marketing_train,ypred_per))
#0.2~0.25部分でsuccessが多い・
#その部分の特徴は

analyze_data(bank_marketing_train,try_glm)

#データの可視化
#install.packages('esquisse')
#bank_marketing_train$ressession = as.factor(bank_marketing_train$ressession)
#bank_marketing_train$y_pred<-predict(try_glm, newdata = bank_marketing_train, type="response")
#bank_marketing_train$y_line<-predict(try_glm, newdata = bank_marketing_train, type="link")
#esquisse::esquisser(bank_marketing_train)
