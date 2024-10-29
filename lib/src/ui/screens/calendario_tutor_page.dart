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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked.minute == 0) {
      setState(() {
        _oraInizioSelezionata = picked;
      });
    } else {
      setState(() {
        erroreFascia = "Seleziona solo ore esatte (es. 14:00)";
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarioViewModel = Provider.of<CalendarioViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Tutor'),
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
              onPressed: _aggiungiFasciaOraria,
              child: const Text('Aggiungi Fascia Oraria'),
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