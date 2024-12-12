import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/calendario_view_model.dart';

class CalendarioTutorPage extends StatefulWidget {
  final String tutorId;  // ID del tutor

  const CalendarioTutorPage({required this.tutorId, super.key});

  @override
  _CalendarioTutorPageState createState() => _CalendarioTutorPageState();
}

class _CalendarioTutorPageState extends State<CalendarioTutorPage> {
  DateTime? _dataSelezionata;
  TimeOfDay? _oraInizioSelezionata;
  String? erroreFascia;

  @override
  void initState() {
    super.initState();
    // Attiva il listener in tempo reale per le fasce orarie
    Provider.of<CalendarioViewModel>(context, listen: false).listenToFasceOrarie(widget.tutorId, true);
  }

  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dataSelezionata = DateTime(picked.year, picked.month, picked.day, 0, 0, 0, 0, 0);
      });
    }
  }


  Future<void> _selezionaOraInizio(BuildContext context) async {

    if (_dataSelezionata == null) {
      // Mostra uno SnackBar se la data non è stata selezionata
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleziona prima la data"),
          backgroundColor: Colors.black,
        ),
      );
      return; // Esci dalla funzione
    }

    final now = DateTime.now();
    final calendarioViewModel = Provider.of<CalendarioViewModel>(context, listen: false);

    // Determina l'ora corrente se la data selezionata è oggi
    final isToday = _dataSelezionata?.day == now.day &&
        _dataSelezionata?.month == now.month &&
        _dataSelezionata?.year == now.year;

    final fasceEsistenti = calendarioViewModel.fasceOrarie.where((fascia) {
      return calendarioViewModel.compareDateOnly(fascia.data, _dataSelezionata!) == 0;
    }).toList();

    final availableHours = List<int>.generate(24, (index) => index).where((hour) {
      if (isToday && hour <= now.hour) {
        return false; // Filtra ore passate
      }
      // Filtra le ore già presenti
      return !fasceEsistenti.any((fascia) {
        final inizio = int.parse(fascia.oraInizio.split(':')[0]);
        return hour == inizio;
      });
    }).toList();


    // Mostra il selettore di ore con solo le ore disponibili
    final pickedHour = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Seleziona Ora',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: availableHours.length,
                  itemBuilder: (context, index) {
                    final hour = availableHours[index];
                    return ListTile(
                      title: Text('${hour.toString().padLeft(2, '0')}:00'),
                      onTap: () {
                        Navigator.of(context).pop(hour);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (pickedHour != null) {
      setState(() {
        _oraInizioSelezionata = TimeOfDay(hour: pickedHour, minute: 0);
        erroreFascia = null;
      });
    }
  }



  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _aggiungiFasciaOraria() {
    if (_dataSelezionata != null && _oraInizioSelezionata != null) {
      final oraFine = TimeOfDay(
        hour: _oraInizioSelezionata!.hour + 1,
        minute: 0,
      );

      Provider.of<CalendarioViewModel>(context, listen: false)
          .aggiungiFasciaOraria(widget.tutorId, _dataSelezionata!, _oraInizioSelezionata!, oraFine);

      // Resetta l'ora selezionata dopo l'aggiunta
      setState(() {
        _oraInizioSelezionata = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarioViewModel = Provider.of<CalendarioViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Tutor'),
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove la freccia indietro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crea Fascia Oraria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selezionaData(context),
              child: Text(_dataSelezionata == null
                  ? 'Seleziona Data'
                  : 'Data: ${_dataSelezionata!.toLocal().toString().split(' ')[0]}'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selezionaOraInizio(context),
              child: Text(_oraInizioSelezionata == null
                  ? 'Seleziona Ora Inizio'
                  : 'Ora Inizio: ${formatTimeOfDay(_oraInizioSelezionata!)}'),
            ),
            if (erroreFascia != null) ...[
              const SizedBox(height: 8),
              Text(
                erroreFascia!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calendarioViewModel.isLoading ? null : _aggiungiFasciaOraria,
              child: calendarioViewModel.isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text('Aggiungi Fascia Oraria'),
            ),
            // Aggiungi il ValueListenableBuilder qui per mostrare eventuali errori
            ValueListenableBuilder<String?>(
              valueListenable: calendarioViewModel.errorNotifier,
              builder: (context, errorMessage, _) {
                if (errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Orari Lezioni',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: calendarioViewModel.fasceOrarie.isEmpty
                  ? const Center(child: Text('Nessuna fascia oraria disponibile'))
                  : ListView.builder(
                itemCount: calendarioViewModel.fasceOrarie.length,
                itemBuilder: (context, index) {
                  final fascia = calendarioViewModel.fasceOrarie[index];

                  String statoPrenotazione = fascia.statoPren
                      ? 'Prenotata'
                      : 'Disponibile';

                  return ListTile(
                    title: Text(
                      'Data: ${fascia.data.toLocal().toString().split(' ')[0]} - ${fascia.oraInizio} / ${fascia.oraFine}',
                    ),
                    subtitle: Text('Stato: $statoPrenotazione'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (fascia.statoPren) {
                          _showCannotDeleteDialog(context);
                        } else {
                          Provider.of<CalendarioViewModel>(context, listen: false)
                              .eliminaFasciaOraria(fascia.tutorRef.id, fascia.data, fascia.oraInizio);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showCannotDeleteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Lezione Prenotata"),
        content: const Text(
            "Prima di eliminare la lezione, devi eliminare la prenotazione associata.\nRicorda di informare lo studente di questa tua decisione."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiude il dialog
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}