const int _hundredThousand = 100000;

double calculateOrderInverse(int segmentIndex, int order) => (order - (_hundredThousand * segmentIndex)).toDouble();
