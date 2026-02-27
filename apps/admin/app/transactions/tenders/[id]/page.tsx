export default function TenderDetailPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <h1>Tender Detail: {params.id}</h1>
    </div>
  );
}
