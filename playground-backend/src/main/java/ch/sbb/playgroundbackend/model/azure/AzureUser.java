package ch.sbb.playgroundbackend.model.azure;

public record AzureUser(String companyName, String createdDateTime, String displayName, String givenName, String id,
                        String mail, String onPremisesSamAccountName, String onPremisesSecurityIdentifier,
                        String onPremisesUserPrincipalName, String preferredLanguage, String surname,
                        String userPrincipalName, String userType) {
}
