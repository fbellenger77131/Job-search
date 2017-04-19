public with sharing class OpenedOpportunities_ListView {

    public PageReference RedirectTo() {
        return GetListViewURL('Open_opportunities_live','Opportunity');
    }
    
    private PageReference GetListViewURL( String LV_DeveloperName, String LV_TargetObject ) {
        List<ListView> lv = [SELECT Id FROM ListView WHERE DeveloperName = :LV_DeveloperName AND SobjectType = :LV_TargetObject LIMIT 1];
        
        if (lv.size() > 0) {
            PageReference lv_url = new PageReference('/006?fcf=' + lv[0].id);
            system.debug('SOQL List View = ' + lv );
            system.debug('List View URL = ' + lv_url );
            return lv_url;
        } else {
            return null;
        }
    }

}