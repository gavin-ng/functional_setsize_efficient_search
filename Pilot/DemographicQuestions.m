function DemographicQuestions(subjectID)

global DemographicResponses 

DemographicResponses = repmat(struct('Subject_ID',-1, 'Age', -1, 'Room', -1, 'Gender', -1, 'Ethnicity',-1, 'First_Language', -1, 'Preferred_Hand',-1, 'Color_Blind',-1),0) ;

DemographicResponses(subjectID).Subject_ID = subjectID ; 


Age = input('What is your age? ') ;
DemographicResponses(subjectID).Age = Age ;


Room = menu('Experiment room:', 'A', 'B', 'D', 'E') ;
DemographicResponses(subjectID).Room = Room ; 


Color_Blind = menu('Sees color?','Yes','No') ; 
DemographicResponses(subjectID).Color_Blind = Color_Blind ;


Gender = menu('What is your gender?', 'Female', 'Male', 'Other', 'Prefer not to answer') ; 
DemographicResponses(subjectID).Gender = Gender ; 


Ethnicity = menu('What is your ethnicity?','Asian','Black','Hispanic','Multiracial','White','Other', 'Prefer not to answer') ; 
DemographicResponses(subjectID).Ethnicity = Ethnicity ;


First_Language = menu('What is your first language?','Chinese','Spanish','English','Other') ;
DemographicResponses(subjectID).First_Language = First_Language ;


Preferred_Hand = menu('What is your preferred hand?','Left','Right') ; 
DemographicResponses(subjectID).Preferred_Hand = Preferred_Hand ; 





DemographicInformation = struct2table(DemographicResponses) ; 
filename = ['DemographicInformation_',num2str(subjectID),'.csv'] ;  
writetable(DemographicInformation, filename, 'Delimiter', ',') ;
save(['DemographicInformation_',num2str(subjectID),'.mat']) ; 
end