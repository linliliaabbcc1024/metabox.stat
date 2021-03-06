#" univariateanalysis_twowayIndependentGroups
#"
#" stat
#" @param e2 = twowayIndependentGroups[[1]];f2=twowayIndependentGroups[[2]];p2=twowayIndependentGroups[[3]];
#" @keywords
#" @export
#" @examples
#" univariateanalysis_twowayIndependentGroups()

univariateanalysis_twowayIndependentGroups <- function(e2,f2,p2,
                                                      group1 = "species",group2 = "treatment",
                                                      para = T,
                                                      parainteraction = T,
                                                      paramaineffect = T,paramaineffectvariance=F,paramaineffectadj = "fdr",paramaineffectpost = "games.howell",
                                                      parasimplemaineffect = T,parasimplemaineffectvariance=F,parasimplemaineffectadj = "fdr",parasimplemaineffectpost = "games.howell",
                                                      paraposthoc = "games.howell",


                                                      # group1 = 'Gender';group2="treatment"
                                                      # para = T;
                                                      # parainteraction = T;
                                                      # paramaineffect = T;paramaineffectvariance=F;paramaineffectadj = "fdr";paramaineffectpost = "games.howell";
                                                      # parasimplemaineffect = T;parasimplemaineffectvariance=F;parasimplemaineffectadj = "fdr";parasimplemaineffectpost = "games.howell";
                                                      # paraposthoc = "games.howell";nonpara = T;nonpposthoc = "t test";nonpposthocadj="bonferroni";

                                                      nonpara = T,
                                                      nonparainteraction = F,
                                                      nonparamaineffect = T,nonparamaineffectvariance=F,nonparamaineffectadj = "fdr",nonparamaineffectpost = "pairwiseUtest",
                                                      nonparasimplemaineffect = T,nonparasimplemaineffectvariance=F,nonparasimplemaineffectadj = "fdr",nonparasimplemaineffectpost = "pairwiseUtest",
                                                      nonparaposthoc = "pairwiseUtest",


                                                      # nonpara = T;
                                                      # nonparainteraction = F;
                                                      # nonparamaineffect = T;nonparamaineffectvariance=F;nonparamaineffectadj = "fdr";nonparamaineffectpost = "pairwiseUtest";
                                                      # nonparasimplemaineffect = T;nonparasimplemaineffectvariance=F;nonparasimplemaineffectadj = "fdr";nonparasimplemaineffectpost = "pairwiseUtest";
                                                      # nonparaposthoc = "pairwiseUtest";


                                                      multicore = TRUE){
  library(parallel);library(userfriendlyscience);library(ez);library(jsonlite)
  if(multicore){
    cl = makeCluster(detectCores())
  }else{
    cl = makeCluster(1)
  }






  #parametric
  if(para){
    #interaction
    if(parainteraction){
     interaction = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,ezANOVA){
       ezANOVA(data = data.frame(value=e2[j,],var1=p2[[group1]],var2=p2[[group2]],id=as.factor(p2[["ID"]])),
               dv = value, wid = id, between = .(var1,var2), type = 3)$ANOVA[3,5]
     },e2,p2,group1,group2,ezANOVA)
    }
    #main effect
    if(paramaineffect){
      # var1
      if(length(unique(p2[[group1]]))==2){
        paravar1main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,paramaineffectvariance){
          oneway.test(e2[j,] ~ as.factor(p2[[group1]]), var.equal = paramaineffectvariance)$p.value
        },e2,p2,group1,group2,paramaineffectvariance)
        paravar1main = rbind(paravar1main,adj = p.adjust(paravar1main,paramaineffectadj))
        rownames(paravar1main) = c(paste0("pvalue_para_ttest(",group1,")"),paste0("pvalue_para_ttest_adj(",group1,")"))
      }else{
        paravar1main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,paramaineffectvariance,posthocTGH,paramaineffectpost){
          paraANOVAposthoc = posthocTGH(e2[j,],as.factor(p2[[group1]]),digits = 4)$output[[paramaineffectpost]][,3]
          return(c(oneway.test(e2[j,] ~ as.factor(p2[[group1]]), var.equal = paramaineffectvariance)$p.value,paraANOVAposthoc))
        },e2,p2,group1,group2,paramaineffectvariance,posthocTGH,paramaineffectpost)
        rownames(paravar1main)[1] = paste0("pvalue_para_ANOVA(",group1,")")
        rownames(paravar1main)[2:nrow(paravar1main)] = paste0("pvalue_para_posthoc(",group1,")_",rownames(paravar1main)[-1])
      }
      # var2
      if(length(unique(p2[[group2]]))==2){
        paravar2main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,paramaineffectvariance){
          oneway.test(e2[j,] ~ as.factor(p2[[group2]]), var.equal = paramaineffectvariance)$p.value
        },e2,p2,group1,group2,paramaineffectvariance)
        paravar2main = rbind(paravar2main,adj = p.adjust(paravar2main,paramaineffectadj))
        rownames(paravar2main) = c(paste0("pvalue_para_ttest(",group2,")"),paste0("pvalue_para_ttest_adj(",group2,")"))
      }else{
        paravar2main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,paramaineffectvariance,posthocTGH,paramaineffectpost){
          paraANOVAposthoc = posthocTGH(e2[j,],as.factor(p2[[group2]]),digits = 4)$output[[paramaineffectpost]][,3]
          return(c(oneway.test(e2[j,] ~ as.factor(p2[[group2]]), var.equal = paramaineffectvariance)$p.value,paraANOVAposthoc))
        },e2,p2,group1,group2,paramaineffectvariance,posthocTGH,paramaineffectpost)
        rownames(paravar2main)[1] = paste0("pvalue_para_ANOVA(",group2,")")
        rownames(paravar2main)[2:nrow(paravar2main)] = paste0("pvalue_para_posthoc(",group2,")_",rownames(paravar2main)[-1])
      }
    }
    #simple main effect
    if(parasimplemaineffect){
      # var1
      if(length(unique(p2[[group1]]))==2){
        paravar1simplemain = by(p2,p2[[group2]],FUN=function(x){ # x=p2[p2[[group2]]==p2[[group2]][1],]
                                e=e2[,p2[[group2]]%in%x[[group2]]];p=x
                                paravar1simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2,parasimplemaineffectvariance){
                                  oneway.test(e[j,] ~ as.factor(p[[group1]]), var.equal = parasimplemaineffectvariance)$p.value
                                },e,p,group1,group2,parasimplemaineffectvariance)
                                paravar1simplemain = rbind(paravar1simplemain,adj = p.adjust(paravar1simplemain,parasimplemaineffectadj))
                                rownames(paravar1simplemain) = c(paste0("pvalue_para_ttest(",p[[group2]][1],":",group1,")"),paste0("pvalue_para_ttest_adj(",p[[group2]][1],":",group1,")"))
                                return(paravar1simplemain)
                              })
      }else{
        paravar1simplemain = by(p2,p2[[group2]],FUN=function(x){ # x=p2[p2[[group2]]==p2[[group2]][1],]
          e=e2[,p2[[group2]]%in%x[[group2]]];p=x
          paravar1simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2,parasimplemaineffectvariance,posthocTGH,parasimplemaineffectpost){
            paraANOVAposthoc = posthocTGH(e[j,],as.factor(p[[group1]]),digits = 4)$output[[parasimplemaineffectpost]][,3]
            return(c(oneway.test(e[j,] ~ as.factor(p[[group1]]), var.equal = parasimplemaineffectvariance)$p.value,paraANOVAposthoc))
          },e,p,group1,group2,parasimplemaineffectvariance,posthocTGH,parasimplemaineffectpost)
          rownames(paravar1simplemain)[1] = paste0("pvalue_para_ANOVA(",p[[group2]][1],":",group1,")")
          rownames(paravar1simplemain)[2:nrow(paravar1simplemain)] = paste0("pvalue_para_posthoc(",p[[group2]][1],":",group1,")_",rownames(paravar1simplemain)[-1])
          return(paravar1simplemain)
        })
      }
      # var2
      if(length(unique(p2[[group2]]))==2){
        paravar2simplemain = by(p2,p2[[group1]],FUN=function(x){ # x=p2[p2[[group1]]==p2[[group1]][1],]
          e=e2[,p2[[group1]]%in%x[[group1]]];p=x
          paravar2simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2,parasimplemaineffectvariance){
            oneway.test(e[j,] ~ as.factor(p[[group2]]), var.equal = parasimplemaineffectvariance)$p.value
          },e,p,group1,group2,parasimplemaineffectvariance)
          paravar2simplemain = rbind(paravar2simplemain,adj = p.adjust(paravar2simplemain,parasimplemaineffectadj))
          rownames(paravar2simplemain) = c(paste0("pvalue_para_ttest(",p[[group1]][1],":",group2,")"),paste0("pvalue_para_ttest_adj(",p[[group1]][1],":",group2,")"))
          return(paravar2simplemain)
        })
      }else{
        paravar2simplemain = by(p2,p2[[group1]],FUN=function(x){ # x=p2[p2[[group1]]==p2[[group1]][1],]
          e=e2[,p2[[group1]]%in%x[[group1]]];p=x
          paravar2simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2,parasimplemaineffectvariance,posthocTGH,parasimplemaineffectpost){
            paraANOVAposthoc = posthocTGH(e[j,],as.factor(p[[group2]]),digits = 4)$output[[parasimplemaineffectpost]][,3]
            return(c(oneway.test(e[j,] ~ as.factor(p[[group2]]), var.equal = parasimplemaineffectvariance)$p.value,paraANOVAposthoc))
          },e,p,group1,group2,parasimplemaineffectvariance,posthocTGH,parasimplemaineffectpost)
          rownames(paravar2simplemain)[1] = paste0("pvalue_para_ANOVA(",p[[group1]][1],":",group2,")")
          rownames(paravar2simplemain)[2:nrow(paravar2simplemain)] = paste0("pvalue_para_posthoc(",p[[group1]][1],":",group2,")_",rownames(paravar2simplemain)[-1])
          return(paravar2simplemain)
        })
      }
    }
  }
  parasubresult = t(rbind(interaction,paravar1main,paravar2main,do.call("rbind", paravar1simplemain),do.call("rbind", paravar2simplemain)))
  colnames(parasubresult)[1] = paste0("pvalue_para_interaction(",group1,"*",group2,")")


  #nonparametric
  if(nonpara){
    #interaction
    if(nonparainteraction){
      "NonParametric test of independent*independent design is not available."
    }
    #main effect
    if(nonparamaineffect){
      # var1
      if(length(unique(p2[[group1]]))==2){
        nonparavar1main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2){
          wilcox.test(e2[j,] ~ as.factor(p2[[group1]]))$p.value
        },e2,p2,group1,group2)
        nonparavar1main = rbind(nonparavar1main,adj = p.adjust(nonparavar1main,nonparamaineffectadj))
        rownames(nonparavar1main) = c(paste0("pvalue_nonpara_ttest(",group1,")"),paste0("pvalue_nonpara_ttest_adj(",group1,")"))
      }else{
        nonparavar1main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,nonparamaineffectpost){
          x = as.vector(pairwise.wilcox.test(e2[j,],as.factor(p2[[group1]]))$p.value)
          nonparaANOVAposthoc = x[!is.na(x)]
          return(c(oneway.test(e2[j,] ~ as.factor(p2[[group1]]))$p.value,nonparaANOVAposthoc))
        },e2,p2,group1,group2,nonparamaineffectpost)
        rownames(nonparavar1main) = 1:nrow(nonparavar1main)# this is because the pairwise.wilcox.test cannot give me the name.
        rownames(nonparavar1main)[1] = paste0("pvalue_nonpara_ANOVA(",group1,")")
        o = rownames(paravar1main)[-1]
        position = regexpr(')_', o)
        temp.name = substring(o, position+2)
        rownames(nonparavar1main)[2:nrow(nonparavar1main)] = paste0("pvalue_nonpara_posthoc(",group1,")_",temp.name)
      }
      # var2
      if(length(unique(p2[[group2]]))==2){
        nonparavar2main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2){
          wilcox.test(e2[j,] ~ as.factor(p2[[group2]]))$p.value
        },e2,p2,group1,group2)
        nonparavar2main = rbind(nonparavar2main,adj = p.adjust(nonparavar2main,nonparamaineffectadj))
        rownames(nonparavar2main) = c(paste0("pvalue_nonpara_ttest(",group2,")"),paste0("pvalue_nonpara_ttest_adj(",group2,")"))
      }else{
        nonparavar2main = parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2,nonparamaineffectpost){
          #nonparaANOVAposthoc = posthocTGH(e2[j,],as.factor(p2[[group2]]),digits = 4)$output[[nonparamaineffectpost]][,3]
          x = as.vector(pairwise.wilcox.test(e2[j,],as.factor(p2[[group2]]))$p.value)
          nonparaANOVAposthoc = x[!is.na(x)]
          return(c(kruskal.test(e2[j,] ~ as.factor(p2[[group2]]))$p.value,nonparaANOVAposthoc))
        },e2,p2,group1,group2,nonparamaineffectpost)
        rownames(nonparavar2main) = 1:nrow(nonparavar2main)# this is because the pairwise.wilcox.test cannot give me the name.
        rownames(nonparavar2main)[1] = paste0("pvalue_nonpara_ANOVA(",group2,")")
        o = rownames(paravar2main)[-1]
        position = regexpr(')_', o)
        temp.name = substring(o, position+2)
        rownames(nonparavar2main)[2:nrow(nonparavar2main)] = paste0("pvalue_nonpara_posthoc(",group2,")_",temp.name)
      }
    }
    #simple main effect
    if(nonparasimplemaineffect){
      # var1
      if(length(unique(p2[[group1]]))==2){
        nonparavar1simplemain = by(p2,p2[[group2]],FUN=function(x){ # x=p2[p2[[group2]]==p2[[group2]][1],]
          e=e2[,p2[[group2]]%in%x[[group2]]];p=x
          nonparavar1simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2){
            wilcox.test(e[j,] ~ as.factor(p[[group1]]))$p.value
          },e,p,group1,group2)
          nonparavar1simplemain = rbind(nonparavar1simplemain,adj = p.adjust(nonparavar1simplemain,nonparasimplemaineffectadj))
          rownames(nonparavar1simplemain) = c(paste0("pvalue_nonpara_ttest(",p[[group2]][1],":",group1,")"),paste0("pvalue_nonpara_ttest_adj(",p[[group2]][1],":",group1,")"))
          return(nonparavar1simplemain)
        })
      }else{
        nonparavar1simplemain = by(p2,p2[[group2]],FUN=function(x){ # x=p2[p2[[group2]]==p2[[group2]][1],]
          e=e2[,p2[[group2]]%in%x[[group2]]];p=x
          nonparavar1simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2,nonparasimplemaineffectpost){

            o = as.vector(pairwise.wilcox.test(e[j,],as.factor(p[[group1]]))$p.value)
            nonparaANOVAposthoc = o[!is.na(o)]
            return(c(kruskal.test(e[j,] ~ as.factor(p[[group1]]))$p.value,nonparaANOVAposthoc))
          },e,p,group1,group2,nonparasimplemaineffectpost)

          rownames(nonparavar1simplemain) = 1:nrow(nonparavar1simplemain)
          rownames(nonparavar1simplemain)[1] = paste0("pvalue_nonpara_ANOVA(",p[[group2]][1],":",group1,")")
          o = rownames(paravar1simplemain[[1]])[-1]
          position = regexpr(')_', o)
          temp.name = substring(o, position+2)
          rownames(nonparavar1simplemain)[2:nrow(nonparavar1simplemain)] = paste0("pvalue_nonpara_posthoc(",p[[group2]][1],":",group1,")_",temp.name)
          return(nonparavar1simplemain)
        })
      }
      # var2
      if(length(unique(p2[[group2]]))==2){
        nonparavar2simplemain = by(p2,p2[[group1]],FUN=function(x){ # x=p2[p2[[group1]]==p2[[group1]][1],]
          e=e2[,p2[[group1]]%in%x[[group1]]];p=x
          nonparavar2simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2){
            wilcox.test(e[j,] ~ as.factor(p[[group2]]))$p.value
          },e,p,group1,group2)
          nonparavar2simplemain = rbind(nonparavar2simplemain,adj = p.adjust(nonparavar2simplemain,nonparasimplemaineffectadj))
          rownames(nonparavar2simplemain) = c(paste0("pvalue_nonpara_ttest(",p[[group1]][1],":",group2,")"),paste0("pvalue_nonpara_ttest_adj(",p[[group1]][1],":",group2,")"))
          return(nonparavar2simplemain)
        })
      }else{
        nonparavar2simplemain = by(p2,p2[[group1]],FUN=function(x){ # x=p2[p2[[group1]]==p2[[group1]][1],]
          e=e2[,p2[[group1]]%in%x[[group1]]];p=x
          nonparavar2simplemain = parSapply(cl,1:nrow(e),function(j,e,p,group1,group2,nonparasimplemaineffectpost){
            o = as.vector(pairwise.wilcox.test(e[j,],as.factor(p[[group2]]))$p.value)
            nonparaANOVAposthoc = o[!is.na(o)]
            return(c(kruskal.test(e[j,] ~ as.factor(p[[group2]]))$p.value,nonparaANOVAposthoc))
          },e,p,group1,group2,nonparasimplemaineffectpost)

          rownames(nonparavar2simplemain) = 1:nrow(nonparavar2simplemain)
          rownames(nonparavar2simplemain)[1] = paste0("pvalue_nonpara_ANOVA(",p[[group1]][1],":",group2,")")
          o = rownames(paravar2simplemain[[1]])[-1]
          position = regexpr(')_', o)
          temp.name = substring(o, position+2)
          rownames(nonparavar2simplemain)[2:nrow(nonparavar2simplemain)] = paste0("pvalue_nonpara_posthoc(",p[[group1]][1],":",group2,")_",temp.name)
          return(nonparavar2simplemain)
        })
      }
    }
  }
  nonparasubresult = t(rbind(nonparainteraction_NOTAVAILABLE = NA,nonparavar1main,nonparavar2main,do.call("rbind", nonparavar1simplemain),do.call("rbind", nonparavar2simplemain)))
  colnames(nonparasubresult)[1] = paste0("pvalue_nonpara_interaction(",group1,"*",group2,")")







  result = matrix(NA,nrow = nrow(f2), ncol=ncol(parasubresult)+ncol(nonparasubresult))
  result[!f2$missingremoved,seq(1,ncol(result),2)] = parasubresult
  result[!f2$missingremoved,seq(2,ncol(result),2)] = nonparasubresult
  colnames(result) = 1:ncol(result)

  colnames(result)[seq(1,ncol(result),2)] = colnames(parasubresult)
  colnames(result)[seq(2,ncol(result),2)] = colnames(nonparasubresult)


  # result = data.frame(f2,result,check.names = FALSE)
  # return(list(hypo_test_result=result,hypo_test_result_json=toJSON(result)))
  result = data.frame(f2,result,check.names = F);


  means  = t(parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2){
    dta = data.frame(value = e2[j,],var1=p2[[group1]],var2=p2[[group2]])
    return(aggregate(value~.,data=dta, mean)$value)
  },e2,p2,group1,group2))
  means = data.frame(means,check.names = F)
  dta = data.frame(value = e2[1,],var1=p2[[group1]],var2=p2[[group2]])
  temp.next = aggregate(value~.,data=dta, mean)
  temp.name = vector()
  for(i in 1:nrow(temp.next)){
    temp.name[i] = paste0("mean_",temp.next[i,1],"*",temp.next[i,2])
  }
  colnames(means) = temp.name


  sds  = t(parSapply(cl,1:nrow(e2),function(j,e2,p2,group1,group2){
    dta = data.frame(value = e2[j,],var1=p2[[group1]],var2=p2[[group2]])
    return(aggregate(value~.,data=dta, sd)$value)
  },e2,p2,group1,group2))
  sds = data.frame(sds,check.names = F)
  dta = data.frame(value = e2[1,],var1=p2[[group1]],var2=p2[[group2]])
  temp.next = aggregate(value~.,data=dta, sd)
  temp.name = vector()
  for(i in 1:nrow(temp.next)){
    temp.name[i] = paste0("sd_",temp.next[i,1],"*",temp.next[i,2])
  }
  colnames(sds) = temp.name


  temp = matrix(,nrow=nrow(result), ncol = ncol(result)+ncol(means)+ncol(sds))
  temp[!f2$missingremoved,(ncol(result)+1):ncol(temp)] = data.matrix(data.frame(means,sds,check.names = F))
  temp[,1:ncol(result)] = as.matrix(result)
  temp = data.frame(temp,check.names = F,stringsAsFactors=FALSE)
  colnames(temp) = c(colnames(as.matrix(result)),colnames(data.matrix(data.frame(means,sds,check.names = F))))
  result = temp




  colnames(result) = gsub("\\.", "_", colnames(result))
  result[is.na(result)] = ""
  return(result)
}
