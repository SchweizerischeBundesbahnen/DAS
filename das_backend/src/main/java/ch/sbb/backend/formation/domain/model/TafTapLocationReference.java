package ch.sbb.backend.formation.domain.model;

import java.util.HashMap;
import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;

/**
 * also called StopPoint
 */
@AllArgsConstructor
@EqualsAndHashCode
public class TafTapLocationReference {

    private static final int MAX_UIC_CODE = 99999;
    /**
     * @see <a href="https://uic.org/support-activities/it/article/country-codes">UIC Country Codes</a>
     */
    private static final Map<Integer, String> uicToIsoCountryCodeMap = new HashMap<>();

    static {
        uicToIsoCountryCodeMap.put(10, "FI");
        uicToIsoCountryCodeMap.put(20, "RU");
        uicToIsoCountryCodeMap.put(21, "BY");
        uicToIsoCountryCodeMap.put(22, "UA");
        uicToIsoCountryCodeMap.put(23, "MD");
        uicToIsoCountryCodeMap.put(24, "LT");
        uicToIsoCountryCodeMap.put(25, "LV");
        uicToIsoCountryCodeMap.put(26, "EE");
        uicToIsoCountryCodeMap.put(27, "KZ");
        uicToIsoCountryCodeMap.put(28, "GE");
        uicToIsoCountryCodeMap.put(29, "UZ");
        uicToIsoCountryCodeMap.put(30, "KP");
        uicToIsoCountryCodeMap.put(31, "MN");
        uicToIsoCountryCodeMap.put(32, "VN");
        uicToIsoCountryCodeMap.put(33, "CN");
        uicToIsoCountryCodeMap.put(34, "LA");
        uicToIsoCountryCodeMap.put(40, "CU");
        uicToIsoCountryCodeMap.put(41, "AL");
        uicToIsoCountryCodeMap.put(42, "JP");
        uicToIsoCountryCodeMap.put(44, "BA");
        uicToIsoCountryCodeMap.put(49, "BA");
        uicToIsoCountryCodeMap.put(50, "BA");
        uicToIsoCountryCodeMap.put(51, "PL");
        uicToIsoCountryCodeMap.put(52, "BG");
        uicToIsoCountryCodeMap.put(53, "RO");
        uicToIsoCountryCodeMap.put(54, "CZ");
        uicToIsoCountryCodeMap.put(55, "HU");
        uicToIsoCountryCodeMap.put(56, "SK");
        uicToIsoCountryCodeMap.put(57, "AZ");
        uicToIsoCountryCodeMap.put(58, "AM");
        uicToIsoCountryCodeMap.put(59, "KG");
        uicToIsoCountryCodeMap.put(60, "IE");
        uicToIsoCountryCodeMap.put(61, "KR");
        uicToIsoCountryCodeMap.put(62, "ME");
        uicToIsoCountryCodeMap.put(65, "MK");
        uicToIsoCountryCodeMap.put(66, "TJ");
        uicToIsoCountryCodeMap.put(67, "TM");
        uicToIsoCountryCodeMap.put(68, "AF");
        uicToIsoCountryCodeMap.put(70, "GB");
        uicToIsoCountryCodeMap.put(71, "ES");
        uicToIsoCountryCodeMap.put(72, "RS");
        uicToIsoCountryCodeMap.put(73, "GR");
        uicToIsoCountryCodeMap.put(74, "SE");
        uicToIsoCountryCodeMap.put(75, "TR");
        uicToIsoCountryCodeMap.put(76, "NO");
        uicToIsoCountryCodeMap.put(78, "HR");
        uicToIsoCountryCodeMap.put(79, "SI");
        uicToIsoCountryCodeMap.put(80, "DE");
        uicToIsoCountryCodeMap.put(81, "AT");
        uicToIsoCountryCodeMap.put(82, "LU");
        uicToIsoCountryCodeMap.put(83, "IT");
        uicToIsoCountryCodeMap.put(84, "NL");
        uicToIsoCountryCodeMap.put(85, "CH");
        uicToIsoCountryCodeMap.put(86, "DK");
        uicToIsoCountryCodeMap.put(87, "FR");
        uicToIsoCountryCodeMap.put(88, "BE");
        uicToIsoCountryCodeMap.put(89, "TZ");
        uicToIsoCountryCodeMap.put(90, "EG");
        uicToIsoCountryCodeMap.put(91, "TN");
        uicToIsoCountryCodeMap.put(92, "DZ");
        uicToIsoCountryCodeMap.put(93, "MA");
        uicToIsoCountryCodeMap.put(94, "PT");
        uicToIsoCountryCodeMap.put(95, "IL");
        uicToIsoCountryCodeMap.put(96, "IR");
        uicToIsoCountryCodeMap.put(97, "SY");
        uicToIsoCountryCodeMap.put(98, "LB");
        uicToIsoCountryCodeMap.put(99, "IQ");
    }

    private String countryCodeIso;

    private Integer uicCode;

    /**
     * @return ISO 3166-1 value
     */
    public static String toCountryCodeIso(Integer countryCodeUic) {
        if (countryCodeUic == null) {
            return null;
        }
        String countryCode = uicToIsoCountryCodeMap.get(countryCodeUic);
        if (countryCode == null) {
            throw new UnexpectedProviderData("ISO country code " + countryCodeUic + " not found");
        }
        return countryCode;
    }

    /**
     * @return proprietary short, speaking format within this project. Related to SLOID.
     */
    public String toLocationCode() {
        if (countryCodeIso == null || uicCode == null) {
            throw new UnexpectedProviderData("countryCodeUic or uicCode is null");
        }
        if (uicCode > MAX_UIC_CODE) {
            throw new UnexpectedProviderData("uicCode is larger than expected 5 digits");
        }
        return countryCodeIso + String.format("%05d", uicCode);
    }

}
