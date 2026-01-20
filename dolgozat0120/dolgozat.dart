import "dart:io";

class Property {
    int adoSzam;
    String utca;
    String hazSzam;
    String sav;
    int terulet;

    Property(this.adoSzam, this.utca, this.hazSzam, this.sav, this.terulet);
}

void main() {
    final file = File("utca.txt");
    final lines = file.readAsLinesSync();

    final fees = lines[0].split(' ').map(int.parse).toList();
    final int fee1 = fees[0];
    final int fee2 = fees[1];
    final int fee3 = fees[2];

    List<Property> properties = [];

    for (int i = 1; i < lines.length; i++) {
        final parts = lines[i].split(' ');
        properties.add(Property(int.parse(parts[0]), parts[1], parts[2], parts[3], int.parse(parts[4])));
    }

    int ado(String sav, int terulet, int fee1, int fee2, int fee3) {
        if (terulet <= 100) return 0;

        int fee;
        
        if (sav == 'A') {
            fee = fee1;
        } else if (sav == 'B') {
            fee = fee2;
        } else {
            fee = fee3;
        }

        return (terulet - 100) * fee;
    }

    void fizetendo(List<Property> properties, int fee1, int fee2, int fee3) {
        Map<int, int> totalTax = {};

        for (var p in properties) {
            int fizetendo = ado(p.sav, p.terulet, fee1, fee2, fee3);
            totalTax[p.adoSzam] = (totalTax[p.adoSzam] ?? 0) + fizetendo;
        }

        final out = File("fizetendo.txt");
        final sink = out.openWrite();

        totalTax.forEach((adoszam, osszeg) {
            sink.writeln('$adoszam $osszeg');
            });

        sink.close();
    }

    fizetendo(properties, fee1, fee2, fee3);
}